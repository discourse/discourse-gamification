# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseGamification::GamificationLeaderboardController do
  let(:current_user) { Fabricate(:admin) }
  let!(:create_score) { UserVisit.create(user_id: current_user.id, visited_at: 2.days.ago) }
  let!(:create_topic) { Fabricate(:topic, user: current_user) }
  let!(:leaderboard) { Fabricate(:gamification_leaderboard, name: "test", created_by_id: current_user.id) }
  let!(:leaderboard_2) { Fabricate(:gamification_leaderboard, name: "test_2", created_by_id: current_user.id, from_date: 3.days.ago, to_date: 1.day.ago) }

  before do
    DiscourseGamification::GamificationScore.calculate_scores(since_date: 10.days.ago)
    sign_in(current_user)
  end

  describe "#respond" do
    it "returns users and their calculated scores" do
      get "/leaderboard/#{leaderboard.id}.json"
      expect(response.status).to eq(200)

      data = response.parsed_body
      expect(data["users"][0]["username"]).to eq(current_user.username)
      expect(data["users"][0]["avatar_template"]).to eq(current_user.avatar_template)
      # expect score to be 6 because of 5 points for topic, 1 point for user visist
      expect(data["users"][0]["total_score"]).to eq(6)
    end

    it "only returns users and scores for specified date range" do
      get "/leaderboard/#{leaderboard_2.id}.json"
      expect(response.status).to eq(200)

      data = response.parsed_body
      expect(data["users"][0]["username"]).to eq(current_user.username)
      expect(data["users"][0]["avatar_template"]).to eq(current_user.avatar_template)
      # expect score to be 1 because of 1 point for user visit, and don't include 5 points for topic creation
      # because it is outside of the scope of specified date range
      expect(data["users"][0]["total_score"]).to eq(1)
    end

    it "does not error if visible_groups_ids are empty" do
      current_user = Fabricate(:user)
      sign_in(current_user)
      get "/leaderboard/#{leaderboard.id}.json"
      expect(response.status).to eq(200)
    end

    it "errors if visible_groups_ids are present and user in not a part of a included group" do
      current_user = Fabricate(:user)
      sign_in(current_user)
      # this should probably pass because we want matching empty arrays here
      get "/leaderboard/#{leaderboard.id}.json"
      expect(response.status).to eq(404)
    end
  end
end
