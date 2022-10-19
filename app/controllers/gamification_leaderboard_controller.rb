# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController
  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])
    period = leaderboard.get_period_date(params[:period]&.to_sym)

    raise Discourse::NotFound unless @guardian.can_see_leaderboard?(leaderboard)

    render_serialized(
      {
        leaderboard: leaderboard,
        page: params[:page].to_i,
        for_user_id: current_user&.id,
        period: period,
      },
      LeaderboardViewSerializer,
      root: false,
    )
  end
end
