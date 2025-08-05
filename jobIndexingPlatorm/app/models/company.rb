class Company < ApplicationRecord
  include Sluggable
  include PgSearch::Model
  
  has_many :jobs, dependent: :destroy
  has_many :active_jobs, -> { where(active: true) }, class_name: 'Job'
  
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :domain, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  enum size_category: {
    startup: 0, small: 1, medium: 2, large: 3, enterprise: 4
  }
  
  scope :active, -> { where(active: true) }
  scope :with_jobs, -> { joins(:active_jobs).distinct }
  
  pg_search_scope :search_by_name_and_description,
    against: [:name, :description, :industry],
    using: { tsearch: { prefix: true } }
  
  def to_param
    slug
  end
  
  def jobs_count
    @jobs_count ||= active_jobs.count
  end
  
  def needs_scraping?
    last_scraped_at.nil? || last_scraped_at < 1.day.ago
  end
end