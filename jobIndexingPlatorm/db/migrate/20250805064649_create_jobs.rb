class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.references :company, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :location
      t.boolean :remote
      t.string :employment_type
      t.string :experience_level
      t.string :department
      t.decimal :salary_min
      t.decimal :salary_max
      t.string :salary_currency
      t.json :requirements
      t.json :benefits
      t.string :external_id
      t.string :external_url
      t.datetime :posted_at
      t.datetime :expires_at
      t.boolean :active

      t.timestamps
    end
  end
end
