# frozen_string_literal: true

RSpec.shared_examples "Correct Score Count" do
  let(:current_user) { Fabricate(:user) }
  let(:expected_score) { expected_score }

  describe "#{described_class} handles scores for large data sets" do
    it "has correct total score" do
      DiscourseGamification::GamificationScore.calculate_scores(since_date: "2022-1-1", only_subclass: described_class)
      expect(DiscourseGamification::GamificationScore.find_by(user_id: current_user.id).score).to eq(expected_score)
    end
  end
end

RSpec.describe ::DiscourseGamification::LikeReceived do
  it_behaves_like "Correct Score Count" do
    let(:user) { Fabricate(:user) }

    before do 
      Fabricate.times(10, :post, user: current_user)
      Post.update_all(like_count: 2)
    end

    # ten likes recieved
    let(:expected_score) { 20 }
  end
end

RSpec.describe ::DiscourseGamification::LikeGiven do
  it_behaves_like "Correct Score Count" do
    before do 
      Fabricate.times(10, :post, user: current_user)
      Post.all.each do |p|
        Fabricate(:post_action, user: current_user, post: p)
      end
    end

    # ten likes given
    let(:expected_score) { 10 }
  end
end

RSpec.describe ::DiscourseGamification::PostCreated do
  it_behaves_like "Correct Score Count" do
    before do 
      Fabricate.times(10, :post, user: current_user)
    end

    # ten posts created
    let(:expected_score) { 20 }
  end
end

RSpec.describe ::DiscourseGamification::DayVisited do
  it_should_behave_like "Correct Score Count" do
    before do 
      (Date.new(2022, 01, 01)..Date.new(2022, 01, 30)).each do |date|
        UserVisit.create(user_id: current_user.id, visited_at: date)
      end
    end

    # thirty days visited
    let(:expected_score) { 30 }
  end
end
