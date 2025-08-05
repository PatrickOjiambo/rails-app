class Job < ApplicationRecord
  belongs_to :company

  validates :title, presence: true

  # Scope to find jobs created recently. Useful for the alert system.
  scope :recent, -> { where('created_at >= ?', 24.hours.ago) }
end