# frozen_string_literal: true

describe DiscourseGamification::GamificationScore do
  let(:current_user) { Fabricate(:user) }

  describe "correctly calculates mass amounts of points" do
    it "expects correct score" do
      (Date.new(2022, 01, 01)..Date.new(2022, 01, 30)).each do |date|
        UserVisit.create(user_id: current_user.id, time_read: 120, visited_at: date)
      end
      DiscourseGamification::GamificationScore.calculate_scores(since_date: "2022-1-1")
      expect(DiscourseGamification::GamificationScore.find_by(user_id: current_user.id).score).to eq(100)
    end
  end
end
