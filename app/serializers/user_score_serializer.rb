# frozen_string_literal: true

class UserScoreSerializer < BasicUserSerializer
  attributes :total_score

  def total_score
    self.user.gamification_score
  end
end
