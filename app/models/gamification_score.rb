# frozen_string_literal: true

class DiscourseGamification::GamificationScore < ::ActiveRecord::Base
  self.table_name = 'gamification_scores'

  belongs_to :user

  def self.enabled_scorables
    DiscourseGamification::Scorable.subclasses.filter { _1.enabled? }
  end

  def self.scorables_queries
    enabled_scorables
      .map { "( #{_1.query} )" }
      .join(' UNION ALL ')
  end

  def self.calculate_scores(since_date: Date.today)
    DB.exec(<<~SQL, since: since_date)
      INSERT INTO gamification_scores (user_id, date, score)
      SELECT user_id, date, SUM(points) AS score
      FROM (
        #{scorables_queries}
      ) AS source
      GROUP BY 1, 2
      ON CONFLICT (user_id, date) DO UPDATE
      SET score = EXCLUDED.score
    SQL
  end
end
