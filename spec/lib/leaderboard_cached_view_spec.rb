# frozen_string_literal: true

require "rails_helper"

describe DiscourseGamification::LeaderboardCachedView do
  fab!(:admin) { Fabricate(:admin) }
  fab!(:user) { Fabricate(:user) }
  fab!(:other_user) { Fabricate(:user) }
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard, created_by_id: admin.id) }
  fab!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id, date: 8.days.ago) }

  let(:mviews) do
    DiscourseGamification::GamificationLeaderboard.periods.map do |period, _|
      "gamification_leaderboard_cache_#{leaderboard.id}_#{period}"
    end
  end

  let(:mview_count_query) { <<~SQL }
      SELECT
        count(*)
      FROM
        pg_class
      WHERE
        relname LIKE 'gamification_leaderboard_cache_#{leaderboard.id}_%'
      AND relkind= 'm'
    SQL

  describe "#create" do
    it "creates a leaderboard materialized view for each period" do
      described_class.new(leaderboard).create

      expect(DB.query_single(mview_count_query).first).to eq(6)
    end
  end

  describe "#refresh" do
    before do
      described_class.new(leaderboard).create
      Fabricate(:gamification_score, user_id: user.id, score: 10)
      Fabricate(:gamification_score, user_id: admin.id, score: 20)
      Fabricate(:gamification_score, user_id: other_user.id, score: 1, date: 5.days.ago)
      Fabricate(:gamification_score, user_id: other_user.id, score: 4, date: 3.days.ago)
    end

    it "refreshes leaderboard materialized views with the latest scores" do
      expect(DB.query_hash("SELECT * FROM #{mviews.first}")).to include(
        { "total_score" => 0, "user_id" => user.id },
        { "total_score" => 0, "user_id" => other_user.id },
        { "total_score" => 0, "user_id" => admin.id },
      )

      described_class.new(leaderboard).refresh

      expect(DB.query_hash("SELECT * FROM #{mviews.first}")).to include(
        { "total_score" => 10, "user_id" => user.id },
        { "total_score" => 5, "user_id" => other_user.id },
        { "total_score" => 20, "user_id" => admin.id },
      )
    end
  end

  describe "#delete" do
    it "deletes all leaderboard materialized views" do
      cached_mview = described_class.new(leaderboard)
      cached_mview.create

      expect(DB.query_single(mview_count_query).first).to eq(6)

      cached_mview.delete

      expect(DB.query_single(mview_count_query).first).to eq(0)
    end
  end
end
