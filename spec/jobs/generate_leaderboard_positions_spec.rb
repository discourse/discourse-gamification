# frozen_string_literal: true

require "rails_helper"

describe Jobs::GenerateLeaderboardPositions do
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard) }
  let(:leaderboard_positions) { DiscourseGamification::LeaderboardCachedView.new(leaderboard) }

  it "generates leaderboard positions" do
    expect { leaderboard_positions.scores }.to raise_error(PG::UndefinedTable)

    DB.active_record_connection.current_transaction.rollback

    described_class.new.execute(leaderboard_id: leaderboard.id)

    expect(leaderboard_positions.scores.length).to eq(1)
  end
end
