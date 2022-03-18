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
      ), scored_directory AS (
        SELECT
          total_score.user_id,
          COALESCE(total_score.score, 0) AS score
        FROM
          total_score
        RIGHT JOIN
          directory_items ON directory_items.period_type = :period_type AND
          total_score.user_id = directory_items.user_id
      )
      UPDATE
        directory_items
      SET
        gamification_score = scored_directory.score
      FROM
        scored_directory
      WHERE
        scored_directory.user_id = directory_items.user_id AND
        directory_items.period_type = :period_type AND
        scored_directory.score != directory_items.gamification_score
    SQL
  end
end
