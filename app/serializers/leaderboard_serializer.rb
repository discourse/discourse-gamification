# frozen_string_literal: true

class LeaderboardSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :created_by_id,
             :from_date,
             :to_date,
             :updated_at
end
