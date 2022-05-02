# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])

    if !current_user.staff? && leaderboard.visible_to_groups_ids.present? && (leaderboard.visible_to_groups_ids & current_user.group_ids).empty?
      raise Discourse::NotFound
    else
      render_serialized({
        leaderboard: leaderboard,
        page: params[:page].to_i,
      }, LeaderboardViewSerializer, root: false)
    end
  end
end
