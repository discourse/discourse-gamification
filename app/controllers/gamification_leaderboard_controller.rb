# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    users = DiscourseGamification::GamificationLeaderboard.scores_for(params[:leaderboard_name])
    render_serialized(users, UserScoreSerializer)
  end
end
