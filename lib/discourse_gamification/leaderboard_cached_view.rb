# frozen_string_literal: true

module ::DiscourseGamification
  class LeaderboardCachedView
    class NotReadyError < StandardError
    end

    # Bump up when materialized view query changes
    QUERY_VERSION = 1
    SCORE_RANKING_STRATEGY_MAP = {
      row_number: "ROW_NUMBER()",
      rank: "RANK()",
      dense_rank: "DENSE_RANK()",
    }

    attr_reader :leaderboard

    def initialize(leaderboard)
      @leaderboard = leaderboard
    end

    def create
      periods.each { |period| create_mview(period) }
    end

    def refresh
      periods.each { |period| refresh_mview(period) }
    end

    def delete
      periods.each { |period| delete_mview(period) }
    end

    def purge_stale
      list = stale_mviews

      return if list.empty?

      DB.exec("DROP MATERIALIZED VIEW IF EXISTS #{list.join(", ")} CASCADE")
    end

    def stale?
      stale_mviews.present?
    end

    def scores(period: "all_time", page: 0, for_user_id: false, limit: nil, offset: nil)
      user_filter_condition = for_user_id ? ["users.id = ?", for_user_id] : [nil]

      User
        .where(*user_filter_condition)
        .joins("INNER JOIN #{mview_name(period)} p ON  p.user_id = users.id")
        .select(
          "users.id, users.name, users.username, users.uploaded_avatar_id, p.total_score, p.position",
        )
        .limit(limit)
        .offset(offset)
        .order(position: :asc, id: :asc)
        .load
    rescue ActiveRecord::StatementInvalid => e
      if PG::UndefinedTable === e.cause
        raise NotReadyError.new(I18n.t("errors.leaderboard_positions_not_ready"))
      else
        raise
      end
    end

    def self.create_all
      GamificationLeaderboard.find_each { |leaderboard| self.new(leaderboard).create }
    end

    def self.refresh_all
      GamificationLeaderboard.find_each { |leaderboard| self.new(leaderboard).refresh }
    end

    def self.delete_all
      GamificationLeaderboard.find_each { |leaderboard| self.new(leaderboard).delete }
    end

    def self.purge_all_stale
      GamificationLeaderboard.find_each { |leaderboard| self.new(leaderboard).purge_stale }
    end

    def self.update_all
      purge_all_stale
      create_all
    end

    def self.regenerate_all
      delete_all
      create_all
    end

    private

    def create_mview(period)
      # NOTE: Update QUERY_VERSION above on changing any of the queries here
      return if mview_exists?(period)

      name = mview_name(period)

      total_scores_query = <<~SQL
        WITH leaderboard AS (
          SELECT * FROM gamification_leaderboards WHERE id = :leaderboard_id
        ),

        leaderboard_users AS (
          SELECT
            u.id
          FROM
            users u
          INNER JOIN
            user_emails ON user_emails.primary = TRUE AND user_emails.user_id = u.id
          CROSS JOIN
            leaderboard lb
          WHERE NOT
            (user_emails.email LIKE '%@anonymized.invalid%')
          AND
            u.staged = FALSE
          AND
            u.id > 0
          AND
            (
              NOT EXISTS(SELECT 1 FROM anonymous_users a WHERE a.user_id = u.id)
            )
          AND
            -- Ensure user is a member of included_groups_ids if it's  not empty
            (
              (COALESCE(array_length(lb.included_groups_ids, 1), 0) = 0)
              OR
              (EXISTS (SELECT 1 FROM group_users AS gu WHERE gu.group_id = ANY(lb.included_groups_ids) AND gu.user_id = u.id))
            )
          AND
            -- Ensure user is not a member of excluded_groups_ids if it's not empty
            (
              (COALESCE(array_length(lb.excluded_groups_ids, 1), 0) = 0)
              OR
              (NOT EXISTS (SELECT 1 FROM group_users AS gu WHERE gu.group_id = ANY(lb.excluded_groups_ids) AND gu.user_id = u.id))
            )
        ),

        scores AS (
          SELECT
            gs.*
          FROM
            gamification_scores gs
          CROSS JOIN
            leaderboard lb
          WHERE
            (
              -- Leaderboard with both "to/from" dates
              -- Only scores created between specified dates
              (
                lb.from_date IS NOT NULL
                AND lb.to_date IS NOT NULL
                AND gs.date BETWEEN lb.from_date AND lb.to_date
              )
              OR
              -- Leaderboard without "from/to" dates. All scores
              (lb.from_date IS NULL AND lb.to_date IS NULL)
              OR
              -- Leaderboard with just "from" date
              -- Only scores created starting from the specified date
              (
                lb.from_date IS NOT NULL
                AND lb.to_date IS NULL
                AND gs.date >= lb.from_date
              )
              OR
              -- Leaderboard with just "to" date
              -- Only scores created up to the specified date
              (
                lb.to_date IS NOT NULL
                AND lb.from_date IS NULL
                AND gs.date <= lb.to_date
              )
            )
          #{score_period_condtion(period)}
        )

        SELECT
         lu.id AS user_id,
         SUM(COALESCE(s.score, 0)) AS total_score,
         #{ranking_function} OVER (ORDER BY SUM(COALESCE(s.score, 0)) DESC) AS position
        FROM
          leaderboard_users lu
        INNER JOIN
          scores s ON s.user_id = lu.id
        GROUP BY
          lu.id
        ORDER BY
          position ASC,
          user_id ASC
      SQL

      mview_query = <<~SQL
        CREATE MATERIALIZED VIEW IF NOT EXISTS #{name} AS
        #{total_scores_query}
      SQL

      user_id_index_query = <<~SQL
        CREATE UNIQUE INDEX IF NOT EXISTS user_id_#{leaderboard.id}_#{period}_#{QUERY_VERSION}_index ON #{name} (user_id)
      SQL

      DB.exec(mview_query, leaderboard_id: leaderboard.id)
      DB.exec(user_id_index_query)
    end

    def ranking_function
      SCORE_RANKING_STRATEGY_MAP[SiteSetting.score_ranking_strategy.to_sym]
    end

    def refresh_mview(period)
      return unless mview_exists?(period)

      DB.exec("REFRESH MATERIALIZED VIEW CONCURRENTLY #{mview_name(period)}")
    end

    def mview_exists?(period)
      query = <<~SQL
        SELECT
          1
        FROM
          pg_class
        WHERE
          relname = '#{mview_name(period)}'
        AND relkind = 'm'
      SQL

      DB.exec(query) == 1
    end

    def delete_mview(period)
      DB.exec("DROP MATERIALIZED VIEW IF EXISTS #{mview_name(period)} CASCADE")
    end

    def mview_name(period)
      "gamification_leaderboard_cache_#{leaderboard.id}_#{period}_#{QUERY_VERSION}"
    end

    def periods
      @periods ||= GamificationLeaderboard.periods.keys
    end

    def stale_mviews
      stale_mviews_query = <<~SQL
        SELECT
          relname
        FROM
          pg_class
        WHERE
          relname LIKE 'gamification_leaderboard_cache_#{leaderboard.id}_%'
        AND relkind = 'm'
        AND relname NOT LIKE 'gamification_leaderboard_cache_#{leaderboard.id}_%_#{QUERY_VERSION}'
      SQL

      DB.query_single(stale_mviews_query)
    end

    def score_period_condtion(period)
      date =
        case period
        when "yearly"
          "CURRENT_DATE - INTERVAL '1 year'"
        when "monthly"
          "CURRENT_DATE - INTERVAL '1 month'"
        when "quarterly"
          "CURRENT_DATE - INTERVAL '3 month'"
        when "weekly"
          "CURRENT_DATE - INTERVAL '1 week'"
        when "daily"
          "CURRENT_DATE - INTERVAL '1 day'"
        else
          nil
        end

      date ? "AND gs.date >= #{date}" : ""
    end
  end
end
