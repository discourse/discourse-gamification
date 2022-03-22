RSpec.shared_examples "Scorable Type" do
  
  let(:user) { Fabricate(:user) }
  let(:user_2) { Fabricate(:user) }
  let!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id) }
  let!(:gamification_score_2) { Fabricate(:gamification_score, user_id: user_2.id, date: 2.days.ago) }

  describe "updates gamification score" do
    let!(:create_score) { class_action_fabricator }


    it "#{described_class} updates scores for today" do
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(0)
      DiscourseGamification::GamificationScore.calculate_scores
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(described_class.score_multiplier)
    end

    it "#{described_class} does not update scores for records with dates older than since_date" do
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
      DiscourseGamification::GamificationScore.calculate_scores
      expect(DiscourseGamification::GamificationScore.find_by(user_id: user_2.id).score).to eq(0)
    end

    DiscourseGamification::GamificationScore.destroy_all
  end
end

RSpec.describe ::DiscourseGamification::LikesReceived do
  it_behaves_like "Scorable Type" do 
    let(:post) { Fabricate(:post, user: user) }
    let(:class_action_fabricator) { Fabricate(:post_action, user: user, post: post) }
  end
end
