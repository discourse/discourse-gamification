# frozen_string_literal: true

return if Rails.env.test? || DiscourseGamification::GamificationLeaderboard.find_by(name: "Global Leaderboard")

DiscourseGamification::GamificationLeaderboard.seed(:name) do |leaderboard|
  leaderboard.name = "Global Leaderbaord"
  leaderboard.created_by_id = Discourse.system_user.id
end
