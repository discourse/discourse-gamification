# frozen_string_literal: true

RSpec.shared_examples "Correct Score Count" do
  let(:current_user) { Fabricate(:user) }
  let(:expected_score) { expected_score }

  describe "#{described_class} handles scores for large data sets" do
    it "has correct total score" do
      DiscourseGamification::GamificationScore.calculate_scores(since_date: "2022-1-1", only_subclass: described_class)
      expect(current_user.gamification_score).to eq(expected_score)
    end
  end
end

RSpec.shared_examples "Category Scoped Scorable Type" do
  let(:user) { Fabricate(:user) }
  let(:user_2) { Fabricate(:user) }
  let(:category_allowed) { Fabricate(:category) }
  let(:category_not_allowed) { Fabricate(:category) }
  let(:expected_score) { described_class.score_multiplier }
  let(:after_create_hook) { nil }

  describe "updates gamification score" do
    let!(:create_score) { class_action_fabricator }
    let!(:trigger_after_create_hook) { after_create_hook }

    it "#{described_class} updates scores for action in the category configured" do
      expect(user.gamification_score).to eq(0)
      SiteSetting.scorable_categories = category_allowed.id.to_s
      DiscourseGamification::GamificationScore.calculate_scores(only_subclass: described_class)
      expect(user.gamification_score).to eq(expected_score)
    end

    it "#{described_class} doesn't updates scores for action in the category configured" do
      expect(user_2.gamification_score).to eq(0)
      SiteSetting.scorable_categories = category_not_allowed.id.to_s
      DiscourseGamification::GamificationScore.calculate_scores(only_subclass: described_class)
      expect(user_2.gamification_score).to eq(0)
    end
  end
end

RSpec.describe ::DiscourseGamification::LikeReceived do
  it_behaves_like "Correct Score Count" do
    let(:user) { Fabricate(:user) }

    before do 
      Fabricate.times(10, :post, user: current_user)
      Post.update_all(like_count: 1)
    end

    # ten likes recieved
    let(:expected_score) { 10 }
  end

  it_behaves_like "Category Scoped Scorable Type" do
    let(:topic) { Fabricate(:topic, user: user, category: category_allowed) }
    let(:class_action_fabricator) { Fabricate(:post, user: user, topic: topic) }
    let(:after_create_hook) { Post.update_all(like_count: 1) }

    # 1 like received
    let(:expected_score) { 1 }
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

  it_behaves_like "Category Scoped Scorable Type" do
    let(:topic) { Fabricate(:topic, user: user, category: category_allowed) }
    let(:post) { Fabricate(:post, user: user, topic: topic) }
    let(:class_action_fabricator) { Fabricate(:post_action, user: user, post: post) }

    # one like given
    let(:expected_score) { 1 }
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

RSpec.describe ::DiscourseGamification::PostRead do
  it_should_behave_like "Correct Score Count" do
    before do 
      (Date.new(2022, 01, 01)..Date.new(2022, 01, 30)).each do |date|
        UserVisit.create(user_id: current_user.id, visited_at: date, posts_read: 5)
      end
    end

    # thirty days of reading 5 posts
    let(:expected_score) { 30 }
  end
end

RSpec.describe ::DiscourseGamification::TimeRead do
  it_should_behave_like "Correct Score Count" do
    before do 
      (Date.new(2022, 01, 01)..Date.new(2022, 01, 30)).each do |date|
        UserVisit.create(user_id: current_user.id, time_read: 60, visited_at: date)
      end
    end

    # thirty days of reading 1 hour
    let(:expected_score) { 30 }
  end
end

RSpec.describe ::DiscourseGamification::FlagCreated do
  it_should_behave_like "Correct Score Count" do
    before do 
      Fabricate.times(10, :reviewable, created_by: current_user) do
        after_create do
          self.update(status: 1)
        end
      end
    end

    # ten flags created
    let(:expected_score) { 100 }
  end
end

RSpec.describe ::DiscourseGamification::TopicCreated do
  it_should_behave_like "Correct Score Count" do
    before do 
      Fabricate.times(10, :topic, user: current_user)
    end

    # ten topics created
    let(:expected_score) { 50 }
  end
end

RSpec.describe ::DiscourseGamification::UserInvited do
  it_should_behave_like "Correct Score Count" do
    before do 
      stub_request(
        :get,
        "http://local.hub:3000/api/customers/-1/account?access_token&admin_count=0&moderator_count=0"
      ).with(
        headers: {
          'Accept' => 'application/json, application/vnd.discoursehub.v1',
          'Host' => 'local.hub:3000',
          'Referer' => 'http://test.localhost'
        }
      ).to_return(status: 200, body: "", headers: {})
      Fabricate.times(10, :invite, invited_by: current_user) do
        after_create do
          self.update(redemption_count: 1)
        end
      end
    end

    # ten users invited
    let(:expected_score) { 100 }
  end
end
