# frozen_string_literal: true

module Jobs
  class GenerateLeaderboardPositions < ::Jobs::Base
    def execute(args)
      leaderboard_id = args[:leaderboard_id]
      raise Discourse::InvalidParameters.new(:leaderboard_id) unless leaderboard_id.present?

      leaderboard = DiscourseGamification::GamificationLeaderboard.find_by(id: leaderboard_id)
      return unless leaderboard

      DiscourseGamification::LeaderboardCachedView.new(leaderboard).create
    end
  end
end
