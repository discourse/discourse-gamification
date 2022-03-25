# frozen_string_literal: true

class GamificationSeeder
  def execute(args = {})
    DiscourseGamfication::GamificationLeaderboard.find_or_initialize_by(
      name: "Global Leaderboard"
      created_by_id: Discourse.system_user.id
    )
  end
end

