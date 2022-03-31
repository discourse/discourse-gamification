# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    default_leaderboard_name = DiscourseGamification::GamificationLeaderboard.first.name
    params[:leaderboard_name] ||= default_leaderboard_name
    users = DiscourseGamification::GamificationLeaderboard.scores_for(params[:leaderboard_name])
    render_serialized(users, UserScoreSerializer)
  end
end
