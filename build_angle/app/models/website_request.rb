class WebsiteRequest < ApplicationRecord
  has_one :generated_website, dependent: :destroy
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :business_type, :design_preferences, presence: true

  # Best Practice: Use enums for status fields. It's cleaner.
  enum status: { pending: 'pending', generating: 'generating', complete: 'complete', failed: 'failed' }
end