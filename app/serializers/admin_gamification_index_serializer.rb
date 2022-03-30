# frozen_string_literal: true

class AdminGamificationIndexSerializer < ApplicationSerializer
  has_many :leaderboards, serializer: LeaderboardSerializer, embed: :objects

  def leaderboards
    object[:leaderboards]
  end
end
