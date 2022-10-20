# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController
  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])
    period =
      case params[:period]&.to_sym
      when :yearly
        1.year.ago
      when :monthly
        1.month.ago
      when :quarterly
        3.months.ago
      when :weekly
        1.week.ago
      when :daily
        1.day.ago
      else
        nil
      end

    raise Discourse::NotFound unless @guardian.can_see_leaderboard?(leaderboard)

    render_serialized(
      {
        leaderboard: leaderboard,
        page: params[:page].to_i,
        for_user_id: current_user&.id,
        period: period,
        user_limit: params[:user_limit]&.to_i,
      },
      LeaderboardViewSerializer,
      root: false,
    )
  end
end
