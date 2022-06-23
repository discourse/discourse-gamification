class AddExcludedGroupsToLeaderboards < ActiveRecord::Migration[7.0]
  def change
    add_column :gamification_leaderboards, :excluded_groups_ids, :integer, array: true, null: false, default: []
  end
end
