# frozen_string_literal: true

require "rails_helper"

describe DiscourseGamification::LeaderboardCachedView do
  fab!(:admin)
  fab!(:user)
  fab!(:other_user) { Fabricate(:user) }
  fab!(:moderator)
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard, created_by_id: admin.id) }
  fab!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id, date: 8.days.ago) }

  let(:mviews) do
    DiscourseGamification::GamificationLeaderboard.periods.map do |period, _|
      "gamification_leaderboard_cache_#{leaderboard.id}_#{period}_#{DiscourseGamification::LeaderboardCachedView::QUERY_VERSION}"
    end
  end

  let(:mview_count_query) { <<~SQL }
      SELECT
        count(*)
      FROM
        pg_class
      WHERE
        relname LIKE 'gamification_leaderboard_cache_#{leaderboard.id}_%'
      AND relkind = 'm'
    SQL

  let(:mview_names_query) { <<~SQL }
      SELECT
        relname
      FROM
        pg_class
      WHERE
        relname LIKE 'gamification_leaderboard_cache_#{leaderboard.id}_%'
      AND relkind = 'm'
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
        { "total_score" => 0, "user_id" => user.id, "position" => 1 },
      )

      described_class.new(leaderboard).refresh

      expect(DB.query_hash("SELECT * FROM #{mviews.first}")).to include(
        { "total_score" => 10, "user_id" => user.id, "position" => 2 },
        { "total_score" => 5, "user_id" => other_user.id, "position" => 3 },
        { "total_score" => 20, "user_id" => admin.id, "position" => 1 },
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

  describe "#purge_stale" do
    it "removes all stale materialized views for leaderboard" do
      stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 1) do
        described_class.new(leaderboard).create
        expect(DB.query_single(mview_count_query).first).to eq(6)
      end

      stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 2) do
        described_class.new(leaderboard).create
        expect(DB.query_single(mview_count_query).first).to eq(12)
      end

      stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 3) do
        described_class.new(leaderboard).create
        expect(DB.query_single(mview_count_query).first).to eq(18)

        described_class.new(leaderboard).purge_stale
        expect(DB.query_single(mview_names_query)).to contain_exactly(*mviews)
      end
    end

    it "does nothing if no stale materialized view exist for leaderboard" do
      described_class.new(leaderboard).create
      expect(DB.query_single(mview_names_query)).to contain_exactly(*mviews)

      described_class.new(leaderboard).purge_stale
      expect(DB.query_single(mview_names_query)).to contain_exactly(*mviews)
    end
  end

  describe "#scores" do
    before do
      Fabricate(:gamification_score, user_id: user.id, score: 20)
      Fabricate(:gamification_score, user_id: admin.id, score: 50)
      Fabricate(:gamification_score, user_id: other_user.id, score: 20)
      Fabricate(:gamification_score, user_id: moderator.id, score: 10)
    end

    let(:leaderboard_positions) { described_class.new(leaderboard) }

    context "with rank ranking strategy" do
      before do
        SiteSetting.score_ranking_strategy = "rank"

        described_class.new(leaderboard).create
      end

      it "returns ranked scores skipping the next rank after duplicates" do
        expect(leaderboard_positions.scores.map(&:attributes)).to eq(
          [
            {
              "total_score" => 50,
              "id" => admin.id,
              "position" => 1,
              "uploaded_avatar_id" => nil,
              "username" => admin.username,
              "name" => admin.name,
            },
            {
              "total_score" => 20,
              "id" => user.id,
              "position" => 2,
              "uploaded_avatar_id" => nil,
              "username" => user.username,
              "name" => user.name,
            },
            {
              "total_score" => 20,
              "id" => other_user.id,
              "position" => 2,
              "uploaded_avatar_id" => nil,
              "username" => other_user.username,
              "name" => other_user.name,
            },
            {
              "total_score" => 10,
              "id" => moderator.id,
              "position" => 4,
              "uploaded_avatar_id" => nil,
              "username" => moderator.username,
              "name" => moderator.name,
            },
          ],
        )
      end
    end

    context "with dense_rank ranking strategy" do
      before do
        SiteSetting.score_ranking_strategy = "dense_rank"

        described_class.new(leaderboard).create
      end

      it "returns ranked scores without skipping the next rank after duplicates" do
        expect(leaderboard_positions.scores.map(&:attributes)).to eq(
          [
            {
              "total_score" => 50,
              "id" => admin.id,
              "position" => 1,
              "uploaded_avatar_id" => nil,
              "username" => admin.username,
              "name" => admin.name,
            },
            {
              "total_score" => 20,
              "id" => user.id,
              "position" => 2,
              "uploaded_avatar_id" => nil,
              "username" => user.username,
              "name" => user.name,
            },
            {
              "total_score" => 20,
              "id" => other_user.id,
              "position" => 2,
              "uploaded_avatar_id" => nil,
              "username" => other_user.username,
              "name" => other_user.name,
            },
            {
              "total_score" => 10,
              "id" => moderator.id,
              "position" => 3,
              "uploaded_avatar_id" => nil,
              "username" => moderator.username,
              "name" => moderator.name,
            },
          ],
        )
      end
    end

    context "with row_number ranking strategy" do
      before do
        SiteSetting.score_ranking_strategy = "row_number"

        described_class.new(leaderboard).create
      end

      it "returns ranked scores without distinguishing duplicates" do
        expect(leaderboard_positions.scores.map(&:attributes)).to eq(
          [
            {
              "total_score" => 50,
              "id" => admin.id,
              "position" => 1,
              "uploaded_avatar_id" => nil,
              "username" => admin.username,
              "name" => admin.name,
            },
            {
              "total_score" => 20,
              "id" => user.id,
              "position" => 2,
              "uploaded_avatar_id" => nil,
              "username" => user.username,
              "name" => user.name,
            },
            {
              "total_score" => 20,
              "id" => other_user.id,
              "position" => 3,
              "uploaded_avatar_id" => nil,
              "username" => other_user.username,
              "name" => other_user.name,
            },
            {
              "total_score" => 10,
              "id" => moderator.id,
              "position" => 4,
              "uploaded_avatar_id" => nil,
              "username" => moderator.username,
              "name" => moderator.name,
            },
          ],
        )
      end
    end
  end
end
