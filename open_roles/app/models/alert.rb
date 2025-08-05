class Alert < ApplicationRecord
  belongs_to :user

  # This gives us a secure, random token for free.
  has_secure_token :unsubscribe_token

  validates :query, presence: true
end