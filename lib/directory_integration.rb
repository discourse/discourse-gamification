# frozen_string_literal: true
class DiscourseGamification::DirectoryIntegration

  def self.query
    "
      UPDATE directory_items
      SET gamification_score = gs.score 
      FROM directory_items di
      INNER JOIN gamification_scores gs
      ON di.user_id = gs.user_id AND COALESCE(gs.date, :since) > :since
      WHERE di.user_id = gs.user_id
      AND di.period_type = :period_type
      AND di.gamification_score <> gs.score
    "
  end
end
