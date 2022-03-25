# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboard < ::ActiveRecord::Base
  self.table_name = 'gamification_leaderboards'

  def self.scores_for(leaderboard_name) 
    leaderboard = self.find_by(name: leaderboard_name)
    leaderboard.to_date ||= Date.today
    scores = DiscourseGamification::GamificationScore.includes(:user)
    scores = scores.where("date < ? AND date > ?", leaderboard.to_date, leaderboard.from_date) if leaderboard.from_date.present?
    scores
  end
end
