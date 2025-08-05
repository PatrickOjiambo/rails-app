class AlertMatch < ApplicationRecord
  belongs_to :alert
  belongs_to :job
  
  validates :match_score, presence: true, 
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  
  scope :unnotified, -> { where(notified: false) }
  scope :high_score, -> { where('match_score >= ?', 0.7) }
  scope :recent, -> { where('created_at > ?', 24.hours.ago) }
  
  def mark_as_notified!
    update!(notified: true, notified_at: Time.current)
  end
end