class CreateAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :alerts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :query
      t.json :filters
      t.string :frequency
      t.boolean :active
      t.datetime :last_run_at
      t.integer :total_matches
      t.string :unsubscribe_token

      t.timestamps
    end
  end
end
