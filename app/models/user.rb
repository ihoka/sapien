class User < ApplicationRecord
  # Associations
  has_many :magic_links, dependent: :destroy
  has_many :otp_codes, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Normalizations
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Methods
  def confirmed?
    email_confirmed?
  end

  def confirm_email!
    update!(
      email_confirmed: true,
      email_confirmed_at: Time.current
    )
  end

  def record_sign_in!
    update!(
      last_sign_in_at: current_sign_in_at,
      current_sign_in_at: Time.current,
      sign_in_count: sign_in_count + 1
    )
  end
end
