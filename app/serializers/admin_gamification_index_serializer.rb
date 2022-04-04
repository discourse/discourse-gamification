# frozen_string_literal: true

class AdminGamificationIndexSerializer < ApplicationSerializer
  has_many :leaderboards, serializer: LeaderboardSerializer, embed: :objects
  has_many :groups, serializer: BasicGroupSerializer, embed: :object

  def leaderboards
    object[:leaderboards]
  end

  def groups
    Group.all
  end
end
