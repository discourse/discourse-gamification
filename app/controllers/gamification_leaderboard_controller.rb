# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])

    if !current_user.staff? && leaderboard.visible_to_groups_ids.present? && (leaderboard.visible_to_groups_ids & current_user.group_ids).empty?
      raise Discourse::NotFound
    else
      p params[:last_user_id]
      render_serialized({
        leaderboard: leaderboard,
        last_user_id: params[:last_user_id],
      }, LeaderboardViewSerializer, root: false)
    end
  end
end
