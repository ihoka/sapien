class OtpService
  def self.generate(user:, purpose:, request:)
    # Generate unique 6-digit code
    code = loop do
      candidate = OtpCode.generate_code
      break candidate unless user.otp_codes.where(code: candidate, purpose: purpose).valid.exists?
    end

    # Create OTP code with 10 minute expiration
    user.otp_codes.create!(
      code: code,
      purpose: purpose,
      expires_at: 10.minutes.from_now,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  def self.verify(email:, code:)
    user = User.find_by(email: email)
    return nil unless user

    otp_code = user.otp_codes.valid.find_by(code: code)
    return nil unless otp_code

    otp_code
  end

  def self.cleanup_expired
    expired_count = OtpCode.expired.count
    OtpCode.expired.delete_all
    expired_count
  end
end
