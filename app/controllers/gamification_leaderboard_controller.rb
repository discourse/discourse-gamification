# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  USER_LIMIT = 20

  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])

    if !current_user.staff? && leaderboard.visible_to_groups_ids.present? && (leaderboard.visible_to_groups_ids & current_user.group_ids).empty?
      raise Discourse::NotFound
    else
      scores_for_users
    end
  end

  private

  def find_leaderboard_user
    # fetch user we are currently viewing 
  end

  def scores_for_users
    users = DiscourseGamification::GamificationLeaderboard.scores_for(params[:id])

    next_users = users
      .where("total_scores < ?", @leaderboard_user.total_score)
      .limit(USER_LIMIT)

    render_serialized(leaderboard, LeaderboardSerializer, root: false)
  end
end
