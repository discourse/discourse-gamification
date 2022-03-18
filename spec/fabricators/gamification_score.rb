# frozen_string_literal: true

Fabricator(:gamification_score, from: ::DiscourseGamification::GamificationScore) do
  user_id { Fabricate(:user).id }
  score { 1 }
  date { Date.today }
end

