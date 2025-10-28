class OtpCode < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :code, presence: true, format: { with: /\A\d{6}\z/ }
  validates :purpose, presence: true, inclusion: { in: %w[signup login] }
  validates :expires_at, presence: true

  # Scopes
  scope :valid, -> { where(verified_at: nil).where("expires_at > ?", Time.current).where("attempts < max_attempts") }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :verified, -> { where.not(verified_at: nil) }

  # Methods
  def valid?
    verified_at.nil? && !expired? && !max_attempts_reached?
  end

  def expired?
    expires_at <= Time.current
  end

  def verified?
    verified_at.present?
  end

  def max_attempts_reached?
    attempts >= max_attempts
  end

  def increment_attempts!
    increment!(:attempts)
  end

  def verify!
    return false unless valid?

    update!(verified_at: Time.current)
    true
  end

  # Class methods
  def self.generate_code
    SecureRandom.random_number(1000000).to_s.rjust(6, "0")
  end
end
