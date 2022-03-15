# frozen_string_literal: true

module Jobs
  class UpdateScoreForToday < ::Jobs::Scheduled
    every 5.minutes

    def execute(args = {})
      DiscourseGamification.find_each do |dg|
        update_score(dg)
      end
    end

    def update_score(dg)
      current_score = dg.score


      dg.calculate_score
      results = DB.query(<<~SQL, group_name: SiteSetting.teambuild_access_group)
        SELECT u.id,
          u.username,
          u.username_lower,
          u.uploaded_avatar_id,
          COUNT(ttu.id) AS score,
          RANK() OVER (ORDER BY COUNT(ttu.id) DESC) AS rank
        FROM users AS u
        LEFT OUTER JOIN teambuild_target_users AS ttu ON ttu.user_id = u.id
        INNER JOIN group_users AS gu ON gu.user_id = u.id
        INNER JOIN groups AS g ON gu.group_id = g.id
        WHERE g.name = :group_name
        GROUP BY u.id, u.name, u.username, u.username_lower, u.uploaded_avatar_id
        ORDER BY score DESC, u.username
      SQL

      new_score = dg
        .where(date: Date.today)
        .score

      return if current_score == new_score

      dg.update(score: new_score)
    end
  end
end
