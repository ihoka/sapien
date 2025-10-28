class MagicLink < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :purpose, presence: true, inclusion: { in: %w[signup login] }
  validates :expires_at, presence: true

  # Scopes
  scope :valid, -> { where(used_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :used, -> { where.not(used_at: nil) }

  # Methods
  def valid?
    used_at.nil? && !expired?
  end

  def expired?
    expires_at <= Time.current
  end

  def used?
    used_at.present?
  end

  def mark_as_used!
    update!(used_at: Time.current)
  end

  # Class methods
  def self.generate_token
    SecureRandom.urlsafe_base64(32)
  end
end
