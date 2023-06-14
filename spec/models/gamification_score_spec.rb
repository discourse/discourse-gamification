# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseGamification::GamificationScore, type: :model do
  fab!(:user) { Fabricate(:user) }

  describe ".calculate_scores" do
    it "calculates the scores properly" do
      Fabricate.times(10, :topic, user: user)
      described_class.calculate_scores
      expect(user.gamification_score).to eq(50)


      user.topics.take(5).each(&:destroy)
      described_class.calculate_scores
      expect(user.gamification_score).to eq(25)

      # this test covers a bug where scores weren't updated if new score was 0
      user.topics.each(&:destroy)
      described_class.calculate_scores
      expect(user.gamification_score).to eq(0)
    end
  end
end
