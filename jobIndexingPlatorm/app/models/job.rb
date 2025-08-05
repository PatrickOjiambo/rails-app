class Job < ApplicationRecord
  include PgSearch::Model
  include Searchable
  
  belongs_to :company
  has_many :alert_matches, dependent: :destroy
  has_many :alerts, through: :alert_matches
  
  validates :title, presence: true
  validates :external_id, uniqueness: { scope: :company_id }, allow_blank: true
  validates :salary_min, :salary_max, numericality: { greater_than: 0 }, allow_nil: true
  
  enum employment_type: {
    full_time: 0, part_time: 1, contract: 2, internship: 3, freelance: 4
  }
  
  enum experience_level: {
    entry: 0, mid: 1, senior: 2, executive: 3
  }
  
  scope :active, -> { where(active: true) }
  scope :remote, -> { where(remote: true) }
  scope :recent, -> { where('posted_at > ?', 30.days.ago) }
  scope :by_company, ->(company) { where(company: company) }
  
  # Full-text search configuration
  pg_search_scope :search_full_text,
    against: {
      title: 'A',
      description: 'B',
      location: 'C',
      department: 'D'
    },
    associated_against: {
      company: [:name, :industry]
    },
    using: {
      tsearch: { prefix: true, any_word: true },
      trigram: { threshold: 0.3 }
    },
    ranked_by: ":tsearch"
  
  before_save :update_search_vector
  after_create :trigger_alert_matching
  
  def salary_range
    return nil unless salary_min && salary_max
    "#{format_salary(salary_min)} - #{format_salary(salary_max)}"
  end
  
  def remote_friendly?
    remote || location&.downcase&.include?('remote')
  end
  
  private
  
  def update_search_vector
    # PostgreSQL full-text search vector update
    # Implementation details...
  end
  
  def trigger_alert_matching
    AlertMatchingJob.perform_async(id)
  end
  
  def format_salary(amount)
    # Salary formatting logic
  end
end