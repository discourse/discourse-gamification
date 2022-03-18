# frozen_string_literal: true

module Jobs
  class UpdateScoresForToday < ::Jobs::Scheduled
    every 5.minutes

    def execute(args = nil)
      DiscourseGamification::GamificationScore.calculate_scores
    end
  end
end
