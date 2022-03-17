class CreateGamificationScoreTable < ActiveRecord::Migration[6.1]
  def change
    create_table :gamification_scores do |t|

      t.integer :user_id, null: false
      t.datetime :date, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :score, null: false
    end
    
    add_index :gamification_scores, [:user_id, :date], unique: true
  end
end
