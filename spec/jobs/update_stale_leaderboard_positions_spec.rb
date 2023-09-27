# frozen_string_literal: true

require "rails_helper"

describe Jobs::UpdateStaleLeaderboardPositions do
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard) }
  let(:leaderboard_positions) { DiscourseGamification::LeaderboardCachedView.new(leaderboard) }

  it "it updates all stale leaderboard positions" do
    stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 1) do
      DiscourseGamification::LeaderboardCachedView.new(leaderboard).create

      expect(leaderboard_positions.scores.length).to eq(1)
      expect(leaderboard_positions.scores.first.to_h).to include(
        user_id: leaderboard.created_by_id,
        total_score: 0,
      )
    end

    stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 2) do
      DiscourseGamification::LeaderboardCachedView.new(leaderboard).create

      expect(leaderboard_positions.scores.length).to eq(1)
      expect(leaderboard_positions.scores.first.to_h).to include(
        user_id: leaderboard.created_by_id,
        total_score: 0,
      )
    end

    stub_const(DiscourseGamification::LeaderboardCachedView, "QUERY_VERSION", 3) do
      # Leaderboard positions exist for `QUERY_VERSION` other than the current version
      expect(leaderboard_positions.stale?).to eq(true)

      ActiveRecord::Base.transaction do
        expect { leaderboard_positions.scores }.to raise_error(PG::UndefinedTable)

        DB.active_record_connection.current_transaction.rollback
      end

      described_class.new.execute

      expect(leaderboard_positions.stale?).to eq(false)
      expect(leaderboard_positions.scores.length).to eq(1)
      expect(leaderboard_positions.scores.first.to_h).to include(
        user_id: leaderboard.created_by_id,
        total_score: 0,
      )
    end
  end
end
