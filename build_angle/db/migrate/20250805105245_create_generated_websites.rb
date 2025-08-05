class CreateGeneratedWebsites < ActiveRecord::Migration[7.1]
  def change
    create_table :generated_websites do |t|
      t.string :subdomain
      t.references :website_request, null: false, foreign_key: true

      t.timestamps
    end
    add_index :generated_websites, :subdomain
  end
end
