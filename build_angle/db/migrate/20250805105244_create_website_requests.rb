class CreateWebsiteRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :website_requests do |t|
      t.string :business_type
      t.text :goals
      t.string :design_preferences
      t.text :content_needs
      t.string :target_audience
      t.string :email
      t.string :status

      t.timestamps
    end
  end
end
