# frozen_string_literal: true

class DiscourseGamification::AdminGamificationLeaderboardController < Admin::AdminController

  def index
    puts "hello friend"
  end

  def create
    params.require([:name, :created_by_id])

    leaderboard = DiscourseGamification::GamificationLeaderboard.new(name: params[:name], created_by_id: params[:created_by_id])
    if leaderboard.save
      puts "saved that shit'"
    else
      puts "didnt saved that shit'"
    end
  end
end
