# frozen_string_literal: true

class DiscourseGamification::GamificationScore < ::ActiveRecord::Base
  self.table_name = 'gamification_scores'

  def self.calculate_scores(for_date: Date.today)
    like_val = SiteSetting.like_score_value
    solution_val = SiteSetting.solution_score_value
    DB.exec(<<~SQL, for_date: for_date, like_val: like_val, solution_val: solution_val)
      WITH x AS (SELECT
        source.user AS user_id,
        SUM(points) AS p_sum
      FROM
      (
      (
        SELECT
          p.user_id AS user,
          COUNT(*) * :like_val AS points
        FROM post_actions pa
        LEFT JOIN posts p ON p.id = pa.post_id
        WHERE post_action_type_id = 2
        AND pa.created_at >= :for_date
        GROUP BY 1
      )
      UNION ALL
      (
      SELECT
        posts.user_id AS user_id,
        COUNT(topic_custom_fields.topic_id) * :solution_val AS points
      FROM
        topic_custom_fields
      INNER JOIN
        topics ON topic_custom_fields.topic_id = topics.id
      INNER JOIN
        posts ON posts.id = topic_custom_fields.value::INTEGER
      WHERE
        topic_custom_fields.name = 'accepted_answer_post_id'
        AND topic_custom_fields.updated_at >= :for_date
      GROUP BY 1
      )
      ) AS source
      GROUP BY 1
      )
      INSERT INTO gamification_scores (user_id, score)
          SELECT * FROM x
          ON CONFLICT (user_id) DO UPDATE SET score = EXCLUDED.score
    SQL
  end
end

