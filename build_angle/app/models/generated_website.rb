class GeneratedWebsite < ApplicationRecord
  belongs_to :website_request
  has_many :generated_pages, dependent: :destroy
  validates :subdomain, presence: true, uniqueness: true
end