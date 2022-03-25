# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    scores = DiscourseGamification::GamificationLeaderboard.scores_for(params[:leaderboard_name])
    puts scores.inspect
    render_serialized(scores, GamificationScoreSerializer, root: false)
  end
end
