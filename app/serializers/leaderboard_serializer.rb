# frozen_string_literal: true

class LeaderboardSerializer < ApplicationSerializer
  has_many :users, serializer: UserScoreSerializer, embed: :objects

  attributes :id,
             :name,
             :created_by_id,
             :from_date,
             :to_date,
             :updated_at

  def users
    DiscourseGamification::GamificationLeaderboard.scores_for(object[:id])
  end
end
