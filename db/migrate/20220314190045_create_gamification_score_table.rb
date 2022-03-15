class CreateGamificationScoreTable < ActiveRecord::Migration[6.1]
  def change
    create_table :gamification_scores do |t|

      t.integer :user_id, null: false
      t.datetime :date, null: false
      t.integer :score, null: false
      t.timestamps
    end

    add_index :gamification_scores, :user_id
    add_index :gamification_scores, :date
  end
end
