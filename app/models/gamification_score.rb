# frozen_string_literal: true

class DiscourseGamification::GamificationScore < ::ActiveRecord::Base
  attr_reader :user_id, :day, :score
  self.table_name = 'gamification_scores'

  def initialize()
  end

  def calculate_score(for_date: Date.today, old_score:)
    DB.exec(<<~SQL, for_date: for_date, old_score: old_score)
      SELECT
        source.user,
        SUM(points)
      FROM
      (
      (
        SELECT
          p.user_id AS user_id,
          COUNT(*) AS points
        FROM post_actions pa
        LEFT JOIN posts p ON p.id = pa.post_id
        WHERE post_action_type_id = 2
        AND pa.created_at > CURRENT_DATE
        GROUP BY 1
        ORDER BY 2 DESC
      )
      UNION ALL
      (
      SELECT
        posts.user_id AS user_id,
        COUNT(topic_custom_fields.topic_id) * 10 AS points
      FROM
        topic_custom_fields
      INNER JOIN
        topics ON topic_custom_fields.topic_id = topics.id
      INNER JOIN
        posts ON posts.id = topic_custom_fields.value::INTEGER
      WHERE
        topic_custom_fields.name = 'accepted_answer_post_id'
        AND topic_custom_fields.updated_at > CURRENT_DATE
      GROUP BY 1
      ORDER BY 2 DESC
      )
      ) AS source
      GROUP BY 1
      ORDER BY 2 DESC
    SQL

  end
end

# == Schema Information
#
# Table name: gamification_scores
#
#  user_id    :integer          not null
#  date       :datetime         not null
#  score      :datetime         not null
#
