# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])

    if !current_user.staff? && leaderboard.visible_to_groups_ids.present? && (leaderboard.visible_to_groups_ids & current_user.group_ids).empty?
      raise Discourse::NotFound
    else
      # we will need to build an object here to include param `page`
      render_serialized(leaderboard, LeaderboardSerializer, root: false)
    end
  end
end
