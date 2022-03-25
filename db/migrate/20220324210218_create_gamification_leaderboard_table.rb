class CreateGamificationLeaderboardTable < ActiveRecord::Migration[6.1]
  def change
    create_table :gamification_leaderboards do |t|
      t.string :name, null: false, unique: true
      t.date :for_date_range, null: true
      t.integer :for_category_id, null: true
      t.integer :created_by_id, null: false
      t.timestamps
    end
  end
end
