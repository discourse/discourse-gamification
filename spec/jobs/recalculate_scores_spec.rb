# frozen_string_literal: true

require "rails_helper"

describe Jobs::RecalculateScores do
  before { RateLimiter.enable }

  it "publishs MessageBus and executes job" do
    since = 10.days.ago
    DiscourseGamification::GamificationScore.expects(:calculate_scores).with(since_date: since)

    MessageBus.expects(:publish).with("/recalculate_scores", { success: true, remaining: 5 }).once
    Jobs::RecalculateScores.new.execute(since: since)
  end
end
