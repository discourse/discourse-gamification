# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboard < ::ActiveRecord::Base
  self.table_name = 'gamification_leaderboards'
  DEFAULT_LEADERBOARD = "Global Leaderboard"

  def self.scores_for(leaderboard_name)
    leaderboard_name ||= DEFAULT_LEADERBOARD
    p leaderboard_name
    p leaderboard_name
    p leaderboard_name
    leaderboard = self.find_by(name: leaderboard_name)
    leaderboard.to_date ||= Date.today

    join_sql = "LEFT OUTER JOIN gamification_scores ON gamification_scores.user_id = users.id"
    sum_sql  = "SUM(COALESCE(gamification_scores.score, 0)) as total_score"
    users = User.joins(join_sql)
    users = users.where("gamification_scores.date BETWEEN ? AND ?", leaderboard.from_date, leaderboard.to_date) if leaderboard.from_date.present?
    users = users.select("users.id, users.username, users.uploaded_avatar_id, #{sum_sql}").group("users.id")
    users
  end
end
