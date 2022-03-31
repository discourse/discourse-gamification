# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseGamification::GamificationLeaderboardController do
  let(:user) { Fabricate(:user) }
  let!(:create_score) { UserVisit.create(user_id: user.id, visited_at: 2.days.ago) }
  let!(:create_topic) { Fabricate(:topic, user: user) }
  let!(:leaderboard) { Fabricate(:gamification_leaderboard, name: "test", created_by_id: user.id) }
  let!(:leaderboard_2) { Fabricate(:gamification_leaderboard, name: "test_2", created_by_id: user.id, from_date: 3.days.ago, to_date: 1.day.ago) }

  before do
    DiscourseGamification::GamificationScore.calculate_scores(since_date: 10.days.ago)
  end

  describe "#respond" do
    it "returns users and their calculated scores" do
      get "/leaderboard/#{leaderboard.id}.json"
      expect(response.status).to eq(200)

      data = response.parsed_body
      expect(data["users"][0]["username"]).to eq(user.username)
      expect(data["users"][0]["avatar_template"]).to eq(user.avatar_template)
      # expect score to be 6 because of 5 points for topic, 1 point for user visist
      expect(data["users"][0]["total_score"]).to eq(6)
    end

    it "only returns users and scores for specified date range" do
      get "/leaderboard/#{leaderboard_2.id}.json"
      expect(response.status).to eq(200)

      data = response.parsed_body
      expect(data["users"][0]["username"]).to eq(user.username)
      expect(data["users"][0]["avatar_template"]).to eq(user.avatar_template)
      # expect score to be 1 because of 1 point for user visit, and don't include 5 points for topic creation
      # because it is outside of the scope of specified date range
      expect(data["users"][0]["total_score"]).to eq(1)
    end
  end
end
