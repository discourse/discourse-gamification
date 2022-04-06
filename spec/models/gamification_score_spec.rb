# frozen_string_literal: true

RSpec.shared_examples "Correct Score Count" do
  let(:current_user) { Fabricate(:user) }
  let(:expected_score) { expected_score }

  before do 
    (DiscourseGamification::Scorable.subclasses - [described_class]).each do |c|
      c.score_multiplier = 0
    end
  end

  describe "#{described_class} handles scores for large data sets" do
    it "has correct total score" do
      DiscourseGamification::GamificationScore.calculate_scores(since_date: "2022-1-1")
      expect(DiscourseGamification::GamificationScore.find_by(user_id: current_user.id).score).to eq(expected_score)
    end
  end
end

RSpec.describe ::DiscourseGamification::LikeReceived do

  it_behaves_like "Correct Score Count" do
    let(:site_setting) { "like_received_score_value" }

    before do 
      Fabricate.times(10, :post, user: current_user)
      Post.all.each do |p|
        Fabricate(:post_action, user: current_user, post: p)
      end
    end

    # expect score to be 8 because of 1 point for like received, 5 points for topic, 2 points for post
    let(:expected_score) { 10 }
  end
end
