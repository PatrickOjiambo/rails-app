class CreateAlertMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :alert_matches do |t|
      t.references :alert, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.decimal :match_score
      t.boolean :notified
      t.datetime :notified_at

      t.timestamps
    end
  end
end
