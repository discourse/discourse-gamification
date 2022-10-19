class AddDefaultPeriodToLeaderboards < ActiveRecord::Migration[7.0]
  def up
    add_column :gamification_leaderboards, :default_period, :integer, default: 0
  end

  def down
    remove_column :gamification_leaderboards, :default_period
  end
end
