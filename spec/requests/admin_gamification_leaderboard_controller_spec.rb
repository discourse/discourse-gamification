# frozen_string_literal: true

RSpec.describe DiscourseGamification::AdminGamificationLeaderboardController do
  fab!(:admin) { Fabricate(:admin) }

  before do
    SiteSetting.discourse_gamification_enabled = true
    sign_in(admin)
  end

  describe "#recalculate_scores" do
    it "enqueues the job with 'since' date" do
      put "/admin/plugins/gamification/recalculate-scores.json", params: { from_date: 10.days.ago }
      expect(response.status).to eq(200)
      expect(Jobs::RecalculateScores.jobs.size).to eq(1)

      job_data = Jobs::RecalculateScores.jobs.first["args"].first
      expect(Date.parse(job_data["since"])).to eq(10.days.ago.midnight)
    end

    it "does not enqueue the job with invalid 'since' date" do
      put "/admin/plugins/gamification/recalculate-scores.json",
          params: {
            from_date: 1.day.from_now,
          }
      expect(response.status).to eq(400)
      expect(Jobs::RecalculateScores.jobs.size).to eq(0)
    end
  end
end
