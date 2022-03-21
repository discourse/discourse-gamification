# frozen_string_literal: true
module DiscourseGamification
  class Scorable
    class << self
      def enabled?
        score_multiplier > 0
      end

      # Should be configurable via a site setting
      def score_multiplier
        0
      end

      # Receives a date and must return a SQL query with three columns:
      #
      #  - user_id
      #  - day
      #  - score
      #
      # Day is the date that this score will be applied too and must be of the
      # `date` type. Should include all scorable events since the `since` param
      # score should be an integer of the score of the day for this module,
      # already multiplied by the score
      def query
        <<~SQL

          SELECT
            user_id AS user_id,
            date_trunc('day', created_at) AS day,
            1 AS score
          FROM
            users

        SQL
      end
    end
  end
end
