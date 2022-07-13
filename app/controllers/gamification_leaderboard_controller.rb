# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboardController < ::ApplicationController

  def respond
    default_leaderboard_id = DiscourseGamification::GamificationLeaderboard.first.id
    params[:id] ||= default_leaderboard_id
    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])
    period =
      case params[:period]&.to_sym
      when :yearly    then 1.year.ago
      when :monthly   then 1.month.ago
      when :quarterly then 3.months.ago
      when :weekly    then 1.week.ago
      when :daily     then 1.day.ago
        else nil
      end

    if !current_user&.staff? && leaderboard.visible_to_groups_ids.present? && (leaderboard.visible_to_groups_ids & current_user&.group_ids).empty?
      raise Discourse::NotFound
    else
      render_serialized({
        leaderboard: leaderboard,
        page: params[:page].to_i,
        for_user_id: current_user&.id,
        period: period
      }, LeaderboardViewSerializer, root: false)
    end
  end
end
