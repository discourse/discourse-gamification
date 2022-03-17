# frozen_string_literal: true
class DiscourseGamification::DirectoryIntegration

  def self.query
    <<~SQL
      WITH total_score AS (
        SELECT
          user_id,
          SUM(score) AS score
        FROM
          gamification_scores
        WHERE
          date >= :since
        GROUP BY
          1
      )
      UPDATE
        directory_items
      SET
        gamification_score = total_score.score
      FROM
        total_score
      WHERE
        total_score.user_id = directory_items.user_id AND
        directory_items.period_type = :period_type AND
        total_score.score != directory_items.gamification_score
    SQL
  end
end
