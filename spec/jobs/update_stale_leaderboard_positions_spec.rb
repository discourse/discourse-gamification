# frozen_string_literal: true

require "rails_helper"

describe Jobs::UpdateStaleLeaderboardPositions do
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard) }
  fab!(:score) { Fabricate(:gamification_score, user_id: leaderboard.created_by_id) }
  let(:leaderboard_positions) { DiscourseGamification::LeaderboardCachedView.new(leaderboard) }

  it "it updates all stale leaderboard positions" do
    stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 1) do
      DiscourseGamification::LeaderboardCachedView.new(leaderboard).create

      expect(leaderboard_positions.scores.length).to eq(1)
      expect(leaderboard_positions.scores.first.attributes).to include(
        "id" => leaderboard.created_by_id,
        "total_score" => 0,
        "position" => 1,
      )
    end

    stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 2) do
      DiscourseGamification::LeaderboardCachedView.new(leaderboard).create

      expect(leaderboard_positions.scores.length).to eq(1)
      expect(leaderboard_positions.scores.first.attributes).to include(
        "id" => leaderboard.created_by_id,
        "total_score" => 0,
      )
    end

    stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 3) do
      # Leaderboard positions exist only for past`QUERY_VERSION`s
      expect(leaderboard_positions.stale?).to eq(true)

      ActiveRecord::Base.transaction do
        expect { leaderboard_positions.scores }.to raise_error(
          DiscourseGamification::LeaderboardCachedView::NotReadyError,
        )
      end

      described_class.new.execute

      expect(leaderboard_positions.stale?).to eq(false)
      expect(leaderboard_positions.scores.length).to eq(1)
      expect(leaderboard_positions.scores.first.attributes).to include(
        "id" => leaderboard.created_by_id,
        "total_score" => 0,
      )
    end
  end
end
