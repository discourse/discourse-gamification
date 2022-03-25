# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboard < ::ActiveRecord::Base
  self.table_name = 'gamification_leaderboards'

  def self.scores_for(leaderboard_name) 
    DiscourseGamification::GamificationScore.all.to_json
  end
end
