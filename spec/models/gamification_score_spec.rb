# frozen_string_literal: true

require 'rails_helper'

describe ::DiscourseGamification::GamificationScore do

  let(:user) { Fabricate(:user) }
  let(:user_2) { Fabricate(:user) }
  let(:post) { Fabricate(:post, user: user) }
  let!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id) }
  let!(:gamification_score_2) { Fabricate(:gamification_score, user_id: user_2.id, date: 2.days.ago) }

  describe "#calculate_scores" do
    let!(:user_liked) { Fabricate(:post_action, user: user, post: post) }

    it "updates scores for today by default" do
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(0)
      DiscourseGamification::GamificationScore.calculate_scores
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(1)
    end

    it "does not update scores for records with dates older than since_date" do
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
      DiscourseGamification::GamificationScore.calculate_scores
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
    end
  end
end
