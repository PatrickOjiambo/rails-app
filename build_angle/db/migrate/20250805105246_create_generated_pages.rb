class CreateGeneratedPages < ActiveRecord::Migration[7.1]
  def change
    create_table :generated_pages do |t|
      t.string :title
      t.string :page_type
      t.text :content
      t.references :generated_website, null: false, foreign_key: true

      t.timestamps
    end
  end
end
