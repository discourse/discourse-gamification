# frozen_string_literal: true

module ::DiscourseGamification
  class GamificationLeaderboard < ::ActiveRecord::Base
    PAGE_SIZE = 100

    self.table_name = "gamification_leaderboards"
    validates :name, exclusion: { in: %w[new], message: "%{value} is reserved." }

    enum :period, { all_time: 0, yearly: 1, quarterly: 2, monthly: 3, weekly: 4, daily: 5 }

    def get_period_date(period_symbol)
      period_symbol ||= GamificationLeaderboard.periods.key(default_period).to_sym

      case period_symbol
      when :all_time
        nil
      when :yearly
        1.year.ago
      when :monthly
        1.month.ago
      when :quarterly
        3.months.ago
      when :weekly
        1.week.ago
      when :daily
        1.day.ago
      else
        nil
      end
    end

    def self.get_cache_key(leaderboard, page, period, user_limit)
      [
        "leaderboard",
        leaderboard.id,
        page,
        period&.strftime('%Y%m%d'),
        user_limit,
        leaderboard.included_groups_ids.present? ? leaderboard.included_groups_ids.join : nil,
        leaderboard.excluded_groups_ids.present? ? leaderboard.excluded_groups_ids.join : nil,
        leaderboard.from_date.present? ? leaderboard.from_date.strftime('%Y%m%d') : nil,
        (leaderboard.to_date != Date.today && !leaderboard.from_date.present?) ? leaderboard.to_date.strftime('%Y%m%d') : nil,
      ].compact.map(&:to_s).join(":")
    end

    def self.scores_for(leaderboard_id, page: 0, for_user_id: false, period: nil, user_limit: nil)
      leaderboard = self.find(leaderboard_id)
      leaderboard.to_date ||= Date.today

      join_sql = "LEFT OUTER JOIN gamification_scores ON gamification_scores.user_id = users.id"
      sum_sql = "SUM(COALESCE(gamification_scores.score, 0)) as total_score"

      cache_key = get_cache_key(leaderboard, page, period, user_limit)

      users = Discourse.cache.read(cache_key) # Shared w/ paged_users and user_position queries
      paged_users = Discourse.cache.read("#{cache_key}:paged")
      user_position = Discourse.cache.read("#{cache_key}:#{for_user_id}") if for_user_id

      if !users
        users =
          User
            .joins(:primary_email)
            .real
            .where.not("user_emails.email LIKE '%@anonymized.invalid%'")
            .where(staged: false)
            .joins(join_sql)
        users =
          users.where(
            "EXISTS (SELECT 1 FROM group_users AS gu WHERE group_id IN (?) and gu.user_id = users.id)",
            leaderboard.included_groups_ids,
          ) if leaderboard.included_groups_ids.present?
        users =
          users.where(
            "NOT EXISTS (SELECT 1 FROM group_users AS gu WHERE group_id IN (?) and gu.user_id = users.id)",
            leaderboard.excluded_groups_ids,
          ) if leaderboard.excluded_groups_ids.present?
        users =
          users.where(
            "gamification_scores.date BETWEEN ? AND ?",
            leaderboard.from_date,
            leaderboard.to_date,
          ) if leaderboard.from_date.present?
        # calculate scores up to to_date if just to_date is present
        users =
          users.where("gamification_scores.date <= ?", leaderboard.to_date) if leaderboard.to_date !=
          Date.today && !leaderboard.from_date.present?
        users = users.where("gamification_scores.date >= ?", period) if period.present?
        users =
          users
            .select("users.id, users.name, users.username, users.uploaded_avatar_id, #{sum_sql}")
            .group("users.id")
            .order(total_score: :desc, id: :asc)
        Discourse.cache.write(cache_key, users, expires_in: 4.hours)
      end

      if for_user_id
        if !user_position
          user = users.find_by(id: for_user_id)
          index = users.index(user)
          user_position = { user: user, position: index ? index + 1 : nil }
          Discourse.cache.write("#{cache_key}:#{for_user_id}", user_position, expires_in: 4.hours)
        end
        return user_position
      end

      if !paged_users
        users = users.offset(PAGE_SIZE * page) if page > 0
        users = users.limit(user_limit || PAGE_SIZE)
        Discourse.cache.write("#{cache_key}:paged", users, expires_in: 4.hours)
      end

      paged_users.present? ? paged_users : users
    end
  end
end

# == Schema Information
#
# Table name: gamification_leaderboards
#
#  id                    :bigint           not null, primary key
#  name                  :string           not null
#  from_date             :date
#  to_date               :date
#  for_category_id       :integer
#  created_by_id         :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  visible_to_groups_ids :integer          default([]), not null, is an Array
#  included_groups_ids   :integer          default([]), not null, is an Array
#  excluded_groups_ids   :integer          default([]), not null, is an Array
#  default_period        :integer          default(0)
#
# Indexes
#
#  index_gamification_leaderboards_on_name  (name) UNIQUE
#
