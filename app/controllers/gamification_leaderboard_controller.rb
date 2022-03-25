# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    @scores = DiscourseGamification::GamificationLeaderboard.scores_for(params[:leaderboard_name])
    puts @scores.inspect
    respond_to do |format|
      format.html
      format.json  { render :json => @scores }
    end 
  end
end
