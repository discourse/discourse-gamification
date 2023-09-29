# frozen_string_literal: true

module Jobs
  class RegenerateLeaderboardPositions < ::Jobs::Base
    def execute(args = nil)
      DiscourseGamification::LeaderboardCachedView.delete_all
      DiscourseGamification::LeaderboardCachedView.create_all
    end
  end
end
