class CreateGamificationScoreTable < ActiveRecord::Migration[6.1]
  def change
    create_table :gamification_scores do |t|

      t.integer :user_id, null: false, index: { unique: true }
      t.datetime :date, null: false, index: true, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :score, null: false
    end
  end
end
