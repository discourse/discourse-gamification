# frozen_string_literal: true
module DiscourseGamification
  class LikeGiven < Scorable

    def self.score_multiplier
      SiteSetting.like_given_score_value
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
          date_trunc('day', pa.created_at) AS date,
          COUNT(*) * #{score_multiplier} AS points
        FROM
          post_actions AS pa
        INNER JOIN posts AS p
          ON p.id = pa.post_id
        #{category_filter}
        WHERE
          p.deleted_at IS NULL AND
          p.wiki IS FALSE AND
          post_action_type_id = 1 AND
          pa.created_at >= :since
        GROUP BY
          1, 2
      SQL
    end
  end
end
