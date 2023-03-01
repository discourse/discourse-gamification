# frozen_string_literal: true
module ::DiscourseGamification
  class Solutions < Scorable
    def self.score_multiplier
      SiteSetting.solution_score_value
    end

    def self.category_filter
      return "" if scorable_category_list.empty?

      <<~SQL
        AND topics.category_id IN (#{scorable_category_list})
      SQL
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
          #{category_filter}
        INNER JOIN posts
          ON posts.id = topic_custom_fields.value::INTEGER
        WHERE
          posts.deleted_at IS NULL AND
          topics.deleted_at IS NULL AND
          topic_custom_fields.name = 'accepted_answer_post_id' AND
          topics.archetype <> 'private_message' AND
          topic_custom_fields.updated_at >= :since
        GROUP BY
          1, 2
      SQL
    end
  end
end
