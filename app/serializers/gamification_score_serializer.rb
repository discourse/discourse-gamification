# frozen_string_literal: true

class GamificationScoreSerializer < ApplicationSerializer
  attributes :id, :score 

  has_one :user, serializer: BasicUserSerializer, embed: :objects
end
