# frozen_string_literal: true

require "rails_helper"

describe Jobs::RefreshLeaderboardPositions do
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard) }
  let(:leaderboard_positions) { DiscourseGamification::LeaderboardCachedView.new(leaderboard) }

  before { leaderboard_positions.create }

  it "refereshes leaderboard positions" do
    Fabricate(:gamification_score, user_id: leaderboard.created_by_id, score: 10)

    expect(leaderboard_positions.scores.length).to eq(1)
    expect(leaderboard_positions.scores[0].to_h).to include(
      user_id: leaderboard.created_by_id,
      total_score: 0,
    )

    described_class.new.execute(leaderboard_id: leaderboard.id)

    expect(leaderboard_positions.scores.length).to eq(1)
    expect(leaderboard_positions.scores[0].to_h).to include(
      user_id: leaderboard.created_by_id,
      total_score: 10,
    )
  end
end
