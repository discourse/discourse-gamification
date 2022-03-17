class AddScoreToDirectoryItems < ActiveRecord::Migration[6.1]
  def up
    add_column :directory_items, :score, :integer, default: 0
  end

  def down
    remove_column :directory_items, :score
  end
end
