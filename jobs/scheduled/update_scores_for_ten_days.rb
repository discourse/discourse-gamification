# frozen_string_literal: true

module Jobs
  class ::DiscourseGamification::UpdateScoresForTenDays < ::Jobs::Scheduled
    every 1.day

    def execute
      DiscourseGamification::GamificationScore.calculate_scores(since_date: 10.days.ago)
    end
  end
end
