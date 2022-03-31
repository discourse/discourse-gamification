# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])

    # check here that we just need 1 group to match 
    if !current_user.staff? && leaderboard.visible_to_groups_ids.present? && !leaderboard.visible_to_groups_ids.include?(current_user.group_ids)
      raise Discourse::NotFound
    else 
      render_serialized(leaderboard, LeaderboardSerializer, root: false)
    end
  end
end
