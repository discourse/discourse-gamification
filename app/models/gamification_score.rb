# frozen_string_literal: true

class DiscourseGamification::GamificationScore < ::ActiveRecord::Base
  self.table_name = 'gamification_scores'

  def self.calculate_scores(since_date: Date.today)
    like_val = SiteSetting.like_score_value
    solution_val = SiteSetting.solution_score_value

    DB.exec(<<~SQL, since_date: since_date, like_val: like_val, solution_val: solution_val)
      INSERT INTO gamification_scores (user_id, date, score)
      SELECT user_id, date, SUM(points) AS score
      FROM (
        (
          SELECT
              p.user_id AS user_id,
              date_trunc('day', pa.created_at) AS date,
              COUNT(*) * :like_val AS points
            FROM
              post_actions AS pa
            INNER JOIN posts AS p
              ON p.id = pa.post_id
            WHERE
              post_action_type_id = 2 AND
              pa.created_at >= :since_date
            GROUP BY
            1, 2
        )
          UNION ALL
        (
            SELECT
              posts.user_id AS user_id,
              date_trunc('day', topic_custom_fields.updated_at) AS date,
              COUNT(topic_custom_fields.topic_id) * :solution_val AS points
            FROM
              topic_custom_fields
            INNER JOIN topics
              ON topic_custom_fields.topic_id = topics.id
            INNER JOIN posts
              ON posts.id = topic_custom_fields.value::INTEGER
            WHERE
              topic_custom_fields.name = 'accepted_answer_post_id' AND
              topic_custom_fields.updated_at >= :since_date
            GROUP BY
              1, 2
        )
      ) AS source
      GROUP BY 1, 2
      ON CONFLICT (user_id, date) DO UPDATE
      SET score = EXCLUDED.score
    SQL
  end
end
