class AuthenticationService
  attr_reader :user, :purpose, :request

  def initialize(user:, purpose:, request:)
    @user = user
    @purpose = purpose
    @request = request
  end

  def send_verification!
    # Generate magic link and OTP code
    magic_link = MagicLinkService.generate(user: user, purpose: purpose, request: request)
    otp_code = OtpService.generate(user: user, purpose: purpose, request: request)

    # Send appropriate email based on purpose
    if purpose == "signup"
      AuthMailer.signup_verification(user: user, magic_link: magic_link, otp_code: otp_code).deliver_later
    else
      AuthMailer.login_verification(user: user, magic_link: magic_link, otp_code: otp_code).deliver_later
    end

    # Log authentication attempt
    Rails.logger.info("Authentication verification sent: user=#{user.email}, purpose=#{purpose}, ip=#{request.remote_ip}")
  end

  def self.verify_magic_link(token:)
    magic_link = MagicLinkService.verify(token: token)
    return nil unless magic_link

    magic_link.mark_as_used!
    magic_link.user
  end

  def self.verify_otp(email:, code:)
    otp_code = OtpService.verify(email: email, code: code)
    return nil unless otp_code

    # Verify the OTP code
    return nil unless otp_code.verify!

    otp_code.user
  end

  def self.create_session(user:, session:)
    # Regenerate session ID for security
    session.clear
    session[:user_id] = user.id

    # Record sign-in
    user.record_sign_in!

    # Log session creation
    Rails.logger.info("Session created: user=#{user.email}")
  end
end
