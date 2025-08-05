class Company < ApplicationRecord
  has_many :jobs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # To make URLs like /companies/uber instead of /companies/1
  def to_param
    slug
  end
end