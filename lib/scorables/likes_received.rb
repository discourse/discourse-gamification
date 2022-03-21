module DiscourseGamification
  class LikesReceived < Scorable
  
    def self.score_multiplier
      SiteSetting.like_score_value
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
        WHERE
          post_action_type_id = 2 AND
          pa.created_at >= :since
        GROUP BY
        1, 2
      SQL
    end
  end
end