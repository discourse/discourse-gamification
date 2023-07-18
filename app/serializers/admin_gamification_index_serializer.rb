# frozen_string_literal: true

class AdminGamificationIndexSerializer < ApplicationSerializer
  attribute :recalculate_scores_remaining
  has_many :leaderboards, serializer: LeaderboardSerializer, embed: :objects
  has_many :groups, serializer: BasicGroupSerializer, embed: :object

  def leaderboards
    object[:leaderboards]
  end

  def groups
    Group.all
  end

  def recalculate_scores_remaining
    DiscourseGamification::RecalculateScoresRateLimiter.remaining
  end
end
