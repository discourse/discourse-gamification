# frozen_string_literal: true

module Jobs
  class RecalculateScores < ::Jobs::Base
    def execute(opts = { since: "2014-8-26" })
      DiscourseGamification::GamificationScore.calculate_scores(since_date: opts[:since])

      ::MessageBus.publish "/recalculate_scores",
                           {
                             success: true,
                             remaining:
                               DiscourseGamification::RecalculateScoresRateLimiter.remaining,
                           }
    end
  end
end
