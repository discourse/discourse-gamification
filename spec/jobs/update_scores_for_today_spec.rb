# frozen_string_literal: true

require "rails_helper"

describe Jobs::UpdateScoresForToday do
  let(:user) { Fabricate(:user) }
  let(:user_2) { Fabricate(:user) }
  let(:post) { Fabricate(:post, user: user) }
  let!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id) }
  let!(:gamification_score_2) do
    Fabricate(:gamification_score, user_id: user_2.id, date: 2.days.ago)
  end
  let!(:topic_user_created) { Fabricate(:topic, user: user) }
  let!(:topic_user_2_created) { Fabricate(:topic, user: user_2) }

  def run_job
    described_class.new.execute
  end

  before { topic_user_2_created.update(created_at: 2.days.ago) }

  it "updates all scores for today" do
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(0)
    run_job
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(5)
  end

  it "does not update scores outside of today" do
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
    run_job
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
  end

  it "purges stale leaderboard positions" do
  end

  it "refreshes leaderboard positions" do
  end

  it "generates new leaderboard positions" do
  end
end
