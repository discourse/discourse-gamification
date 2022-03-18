# frozen_string_literal: true

module Jobs
  class ::DiscourseGamification::UpdateScoresForToday < ::Jobs::Scheduled
    every 5.minutes

    def execute
      DiscourseGamification::GamificationScore.calculate_scores
    end
  end
end
