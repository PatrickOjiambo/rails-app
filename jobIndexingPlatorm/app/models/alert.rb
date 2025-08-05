class Alert < ApplicationRecord
  belongs_to :user
  has_many :alert_matches, dependent: :destroy
  has_many :jobs, through: :alert_matches
  
  validates :name, presence: true
  validates :query, presence: true
  validates :frequency, inclusion: { in: %w[instant daily weekly] }
  
  enum frequency: { instant: 0, daily: 1, weekly: 2 }
  
  scope :active, -> { where(active: true) }
  scope :due_for_processing, -> { 
    where(active: true)
      .where('last_run_at IS NULL OR last_run_at < ?', 1.hour.ago)
  }
  
  before_create :generate_unsubscribe_token
  
  def should_run?
    return false unless active?
    return true if last_run_at.nil?
    
    case frequency
    when 'instant' then last_run_at < 15.minutes.ago
    when 'daily' then last_run_at < 1.day.ago
    when 'weekly' then last_run_at < 1.week.ago
    end
  end
  
  def parsed_filters
    @parsed_filters ||= filters&.with_indifferent_access || {}
  end
  
  private
  
  def generate_unsubscribe_token
    self.unsubscribe_token = SecureRandom.urlsafe_base64(32)
  end
end