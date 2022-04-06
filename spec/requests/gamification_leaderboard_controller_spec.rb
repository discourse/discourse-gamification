# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseGamification::GamificationLeaderboardController do
  let(:group) { Fabricate(:group) }
  let(:current_user) { Fabricate(:user, group_ids: [group.id]) }
  let(:user_2) { Fabricate(:user) }
  let!(:create_score) { UserVisit.create(user_id: current_user.id, visited_at: 2.days.ago) }
  let!(:create_score_2) { UserVisit.create(user_id: user_2.id, visited_at: 2.days.ago) }
  let!(:create_topic) { Fabricate(:topic, user: current_user) }
  let!(:leaderboard) { Fabricate(:gamification_leaderboard, name: "test", created_by_id: current_user.id) }
  let!(:leaderboard_2) { Fabricate(:gamification_leaderboard, name: "test_2", created_by_id: current_user.id, from_date: 3.days.ago, to_date: 1.day.ago) }
  let!(:leaderboard_with_group) { Fabricate(:gamification_leaderboard, name: "test_3", created_by_id: current_user.id, included_groups_ids: [group.id], visible_to_groups_ids: [group.id]) }

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
      expect(data["users"][0]["total_score"]).to eq(current_user.gamification_score)
    end

    it "only returns users and scores for specified date range" do
      get "/leaderboard/#{leaderboard_2.id}.json"
      expect(response.status).to eq(200)

      data = response.parsed_body
      expect(data["users"][0]["username"]).to eq(current_user.username)
      expect(data["users"][0]["avatar_template"]).to eq(current_user.avatar_template)
      expect(data["users"][0]["total_score"]).to eq(current_user.gamification_score)
    end

    it "only returns users that are a part of a group within included_groups_ids" do
      # multiple scores present
      expect(DiscourseGamification::GamificationScore.all.map(&:user_id)).to include(current_user.id, user_2.id)

      get "/leaderboard/#{leaderboard_with_group.id}.json"
      expect(response.status).to eq(200)

      data = response.parsed_body
      # scoped to group
      expect(data["users"].map { |u| u["id"] }).to eq([current_user.id])
    end

    it "does not error if visible_to_groups_ids or included_groups_ids are empty" do
      get "/leaderboard/#{leaderboard.id}.json"
      expect(response.status).to eq(200)
    end

    it "errors if visible_to_groups_ids are present and user in not a part of a included group" do
      current_user.groups = []
      get "/leaderboard/#{leaderboard_with_group.id}.json"
      expect(response.status).to eq(404)
    end

    it "displays leaderboard to users included in group within visible_to_groups_ids" do
      get "/leaderboard/#{leaderboard_with_group.id}.json"
      expect(response.status).to eq(200)
    end

    it "allows admins to see all leaderboards" do
      current_user = Fabricate(:admin)
      sign_in(current_user)
      get "/leaderboard/#{leaderboard_with_group.id}.json"
      expect(response.status).to eq(200)
    end
  end
end
