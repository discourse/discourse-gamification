module DiscourseGamification
  class Solutions < Scorable
  
    def self.score_multiplier
      SiteSetting.solution_score_value
    end

    def self.query
      <<~SQL
        SELECT
          posts.user_id AS user_id,
          date_trunc('day', topic_custom_fields.updated_at) AS date,
          COUNT(topic_custom_fields.topic_id) * #{score_multiplier} AS points
        FROM
          topic_custom_fields
        INNER JOIN topics
          ON topic_custom_fields.topic_id = topics.id
        INNER JOIN posts
          ON posts.id = topic_custom_fields.value::INTEGER
        WHERE
          topic_custom_fields.name = 'accepted_answer_post_id' AND
          topic_custom_fields.updated_at >= :since
        GROUP BY
          1, 2
      SQL
    end
  end
end