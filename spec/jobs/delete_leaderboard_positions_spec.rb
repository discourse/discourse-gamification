# frozen_string_literal: true

require "rails_helper"

describe Jobs::DeleteLeaderboardPositions do
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard) }
  let(:leaderboard_positions) { DiscourseGamification::LeaderboardCachedView.new(leaderboard) }

  before { leaderboard_positions.create }

  it "deletes leaderboard positions" do
    expect(leaderboard_positions.scores.length).to eq(1)

    described_class.new.execute(leaderboard_id: leaderboard.id)

    expect { leaderboard_positions.scores }.to raise_error(PG::UndefinedTable)
  end

  it "deletes leaderboard position even if leaderboard is deleted" do
    leaderboard.destroy

    expect(leaderboard_positions.scores.length).to eq(1)

    described_class.new.execute(leaderboard_id: leaderboard.id)

    expect { leaderboard_positions.scores }.to raise_error(PG::UndefinedTable)
  end
end
