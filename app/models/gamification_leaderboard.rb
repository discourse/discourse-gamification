# frozen_string_literal: true

class DiscourseGamification::GamificationLeaderboard < ::ActiveRecord::Base

  USER_LIMIT = 10

  self.table_name = 'gamification_leaderboards'
  validates :name, exclusion: { in: %w(new),
                                message: "%{value} is reserved." }

  def self.scores_for(leaderboard_id)
    leaderboard = self.find(leaderboard_id)
    leaderboard.to_date ||= Date.today

    join_sql = "LEFT OUTER JOIN gamification_scores ON gamification_scores.user_id = users.id"
    sum_sql = "SUM(COALESCE(gamification_scores.score, 0)) as total_score"
    users = User.real.joins(join_sql)
    users = users.joins(:groups).where(groups: { id: leaderboard.included_groups_ids }) if leaderboard.included_groups_ids.present?
    users = users.where("gamification_scores.date BETWEEN ? AND ?", leaderboard.from_date, leaderboard.to_date) if leaderboard.from_date.present?
    # calculate scores up to to_date if just to_date is present
    users = users.where("gamification_scores.date <= ?", leaderboard.to_date) if leaderboard.to_date != Date.today && !leaderboard.from_date.present?
    users = users.select("users.id, users.username, users.uploaded_avatar_id, #{sum_sql}").group("users.id").order(total_score: :desc).limit(USER_LIMIT)
    users
  end

  # Tie method to a leaderboard so we can handle any category / date scoping
  def total_score_for(user_id)
    leaderboard.to_date ||= Date.today
    users = User.real.joins(join_sql)
    users = users.joins(:groups).where(groups: { id: leaderboard.included_groups_ids }) if leaderboard.included_groups_ids.present?

    users = users.where("gamification_scores.date BETWEEN ? AND ?", leaderboard.from_date, leaderboard.to_date) if leaderboard.from_date.present?
    join_sql = "LEFT OUTER JOIN gamification_scores ON gamification_scores.user_id = users.id"
    sum_sql = "SUM(COALESCE(gamification_scores.score, 0)) as total_score"
  end
end
