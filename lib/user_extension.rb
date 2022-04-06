module DiscourseGamification
  module UserExtension
    def gamification_score
      DiscourseGamification::GamificationScore.where(user_id: self.id).sum(:score)
    end
  end
end
