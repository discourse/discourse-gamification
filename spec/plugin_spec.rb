# frozen_string_literal: true

require "rails_helper"

describe ::DiscourseGamification do
  let(:user) { Fabricate(:user) }
  let!(:gamification_score) { Fabricate(:gamification_score, user_id: user.id) }

  it "adds gamification_score to the UserCardSerializer" do
    serializer = UserCardSerializer.new(user)
    expect(serializer).to respond_to(:gamification_score)
    expect(serializer.gamification_score).to eq(gamification_score.score)
  end
end
