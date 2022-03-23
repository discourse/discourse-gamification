# frozen_string_literal: true

module DiscourseGamification
  class TopicCreated < Scorable

    def self.score_multiplier
      SiteSetting.topic_created_score_value
    end

    def self.query
      <<~SQL
        SELECT
          t.user_id AS user_id,
          date_trunc('day', t.created_at) AS date,
          COUNT(*) * #{score_multiplier} AS points
        FROM
          topics AS t
        WHERE
          t.created_at >= :since
        GROUP BY
          1, 2
      SQL
    end
  end
end
