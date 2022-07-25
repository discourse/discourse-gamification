# frozen_string_literal: true

class DiscourseGamification::AdminGamificationLeaderboardController < Admin::AdminController
  def index
    render_serialized(
      { leaderboards: DiscourseGamification::GamificationLeaderboard.all },
      AdminGamificationIndexSerializer,
      root: false,
    )
  end

  def create
    params.require(%i[name created_by_id])

    leaderboard =
      DiscourseGamification::GamificationLeaderboard.new(
        name: params[:name],
        created_by_id: params[:created_by_id],
      )
    if leaderboard.save
      render_serialized(leaderboard, LeaderboardSerializer, root: false)
    else
      render_json_error(leaderboard)
    end
  end

  def update
    params.require(%i[id name])

    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])
    raise Discourse::NotFound unless leaderboard

    leaderboard.update(
      name: params[:name],
      to_date: params[:to_date],
      from_date: params[:from_date],
      included_groups_ids: params[:included_groups_ids] || [],
      excluded_groups_ids: params[:excluded_groups_ids] || [],
      visible_to_groups_ids: params[:visible_to_groups_ids] || [],
    )

    if leaderboard.save
      render json: success_json
    else
      render_json_error(leaderboard)
    end
  end

  def destroy
    params.require(:id)

    leaderboard = DiscourseGamification::GamificationLeaderboard.find(params[:id])
    leaderboard.destroy if leaderboard
    render json: success_json
  end
end
