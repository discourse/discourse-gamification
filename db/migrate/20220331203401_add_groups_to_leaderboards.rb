class AddGroupsToLeaderboards < ActiveRecord::Migration[6.1]
  def change
    add_column :gamification_leaderboards, :visible_to_groups_ids, :text, array: true, null: false, default: []
    add_column :gamification_leaderboards, :included_groups_ids, :text, array: true, null: false, default: []
  end
end