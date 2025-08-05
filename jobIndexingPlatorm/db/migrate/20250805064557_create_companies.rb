class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :slug
      t.string :domain
      t.text :description
      t.string :logo_url
      t.string :headquarters
      t.integer :size_category
      t.string :industry
      t.json :social_links
      t.boolean :active
      t.datetime :last_scraped_at
      t.json :scraping_config

      t.timestamps
    end
  end
end
