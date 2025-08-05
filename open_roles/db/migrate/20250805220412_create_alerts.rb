class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.string :query
      t.references :user, null: false, foreign_key: true
      t.string :unsubscribe_token

      t.timestamps
    end
    add_index :alerts, :unsubscribe_token, unique: true
  end
end
