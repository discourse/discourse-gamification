# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    users = DiscourseGamification::GamificationLeaderboard.scores_for(params[:leaderboard_name])
    render json: users.to_json
  end
end
