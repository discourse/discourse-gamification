# frozen_string_literal: true

require 'rails_helper'

describe Jobs::UpdateScoresForTenDays do

  let(:user) { Fabricate(:user) }
  let(:user_2) { Fabricate(:user) }
  let(:post) { Fabricate(:post, user: user) }
  let!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id, date: 8.days.ago) }
  let!(:gamification_score_2) { Fabricate(:gamification_score, user_id: user_2.id, date: 12.days.ago) }
  let!(:user_liked) { Fabricate(:post_action, user: user, post: post) }
  let!(:user_2_liked) { Fabricate(:post_action, user: user_2, post: post) }

  def run_job
    described_class.new.execute
  end

  before do
    user_liked.update(created_at: 8.days.ago)
    user_2_liked.update(created_at: 12.days.ago)
  end

  it "updates all scores within the last 10 days" do
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(0)
    run_job
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(1)
  end

  it "does not update scores outside of the last 10 days" do
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
    run_job
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
  end
end
