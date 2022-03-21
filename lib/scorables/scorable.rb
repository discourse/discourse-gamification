# frozen_string_literal: true
module DiscourseGamification
  class Scorable
    class << self
      def enabled?
        score_multiplier > 0
      end
    end
  end
end
