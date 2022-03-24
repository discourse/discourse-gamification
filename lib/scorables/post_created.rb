# frozen_string_literal: true

module DiscourseGamification
  class PostCreated < Scorable

    def self.score_multiplier
      SiteSetting.post_created_score_value
    end

    def self.category_filter
      return '' if scorable_category_list.empty?

      <<~SQL
        INNER JOIN topics
          ON p.topic_id = topics.id AND
          topics.category_id IN (#{scorable_category_list})
      SQL
    end

    def self.query
      <<~SQL
        SELECT
          p.user_id AS user_id,
          date_trunc('day', p.created_at) AS date,
          COUNT(*) * #{score_multiplier} AS points
        FROM
          posts AS p
        #{category_filter}
        WHERE
          p.created_at >= :since
        GROUP BY
          1, 2
      SQL
    end
  end
end
