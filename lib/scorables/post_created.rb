# frozen_string_literal: true

module DiscourseGamification
  class PostCreated < Scorable

    def self.score_multiplier
      SiteSetting.post_created_score_value
    end

    def self.query
      <<~SQL
        SELECT
          p.user_id AS user_id,
          date_trunc('day', p.created_at) AS date,
          COUNT(*) * #{score_multiplier} AS points
        FROM
          posts AS p
        WHERE
          p.created_at >= :since
        GROUP BY
          1, 2
      SQL
    end
  end
end
