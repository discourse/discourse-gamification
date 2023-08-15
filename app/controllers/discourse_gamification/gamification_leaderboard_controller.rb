# frozen_string_literal: true

module ::DiscourseGamification
  class GamificationLeaderboardController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def respond
      discourse_expires_in 1.minute

      default_leaderboard_id = GamificationLeaderboard.first.id
      params[:id] ||= default_leaderboard_id
      leaderboard = GamificationLeaderboard.find(params[:id])
      period = leaderboard.get_period_date(params[:period]&.to_sym)

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
end
