class AuthController < ApplicationController
  skip_before_action :require_authentication, only: [:new_signup, :create_signup, :new_login, :create_login, :verify, :new_otp_verification, :verify_otp, :resend]
  before_action :require_unauthenticated, only: [:new_signup, :create_signup, :new_login, :create_login]

  # GET /auth/signup
  def new_signup
  end

  # POST /auth/signup
  def create_signup
    email = params[:email]&.strip&.downcase

    # Validate email format
    unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:alert] = "Please enter a valid email address"
      return render :new_signup, status: :unprocessable_entity
    end

    # Find or create user
    user = User.find_by(email: email)

    if user&.confirmed?
      # User already exists and confirmed, redirect to login
      redirect_to auth_login_path, notice: "Account already exists. Please log in."
      return
    elsif user && !user.confirmed?
      # User exists but not confirmed, resend verification
      auth_service = AuthenticationService.new(user: user, purpose: "signup", request: request)
      auth_service.send_verification!
    else
      # New user, create account
      user = User.create!(email: email)
      auth_service = AuthenticationService.new(user: user, purpose: "signup", request: request)
      auth_service.send_verification!
    end

    # Store email in session for OTP verification
    session[:pending_email] = email
    session[:pending_purpose] = "signup"

    redirect_to auth_new_otp_verification_path, notice: "Check your email for verification link and code"
  end

  # GET /auth/login
  def new_login
  end

  # POST /auth/login
  def create_login
    email = params[:email]&.strip&.downcase

    # Validate email format
    unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:alert] = "Please enter a valid email address"
      return render :new_login, status: :unprocessable_entity
    end

    # Find user (use generic message to prevent enumeration)
    user = User.find_by(email: email)

    if user && !user.confirmed?
      # User exists but not confirmed, resend signup verification
      auth_service = AuthenticationService.new(user: user, purpose: "signup", request: request)
      auth_service.send_verification!
      session[:pending_email] = email
      session[:pending_purpose] = "signup"
    elsif user && user.confirmed?
      # User exists and confirmed, send login verification
      auth_service = AuthenticationService.new(user: user, purpose: "login", request: request)
      auth_service.send_verification!
      session[:pending_email] = email
      session[:pending_purpose] = "login"
    end
    # If user doesn't exist, still show success message (prevent enumeration)

    redirect_to auth_new_otp_verification_path, notice: "Check your email for login link and code"
  end

  # GET /auth/verify/:token
  def verify
    token = params[:token]

    user = AuthenticationService.verify_magic_link(token: token)

    if user
      # Confirm email if signup
      if user.magic_links.find_by(token: token).purpose == "signup"
        user.confirm_email! unless user.confirmed?
      end

      # Create session
      AuthenticationService.create_session(user: user, session: session)

      redirect_to root_path, notice: "Successfully verified!"
    else
      redirect_to auth_login_path, alert: "Invalid or expired verification link"
    end
  end

  # GET /auth/verify_otp
  def new_otp_verification
    @email = session[:pending_email]
    @purpose = session[:pending_purpose]

    unless @email && @purpose
      redirect_to auth_login_path, alert: "Please request a new verification code"
    end
  end

  # POST /auth/verify_otp
  def verify_otp
    email = params[:email]&.strip&.downcase
    code = params[:code]&.strip

    # Validate inputs
    unless email.present? && code.present?
      return render json: { error: "Email and code are required" }, status: :unprocessable_entity
    end

    # Find user and OTP code
    user = User.find_by(email: email)
    unless user
      return render json: { error: "Invalid code" }, status: :unprocessable_entity
    end

    otp_code = user.otp_codes.valid.find_by(code: code)

    if otp_code.nil?
      # Check if code exists but is invalid
      invalid_otp = user.otp_codes.find_by(code: code)

      if invalid_otp
        if invalid_otp.expired?
          return render json: { error: "Code expired. Request a new code." }, status: :unprocessable_entity
        elsif invalid_otp.max_attempts_reached?
          return render json: { error: "Too many attempts. Request a new code." }, status: :unprocessable_entity
        end
      end

      return render json: { error: "Invalid code" }, status: :unprocessable_entity
    end

    # Try to verify
    if otp_code.verify!
      # Confirm email if signup
      if otp_code.purpose == "signup"
        user.confirm_email! unless user.confirmed?
      end

      # Create session
      AuthenticationService.create_session(user: user, session: session)

      # Clear pending session data
      session.delete(:pending_email)
      session.delete(:pending_purpose)

      render json: { success: true, redirect_url: root_path }
    else
      otp_code.increment_attempts!
      attempts_remaining = otp_code.max_attempts - otp_code.attempts

      render json: {
        error: "Invalid code",
        attempts_remaining: attempts_remaining
      }, status: :unprocessable_entity
    end
  end

  # POST /auth/resend
  def resend
    email = session[:pending_email]
    purpose = session[:pending_purpose]

    unless email && purpose
      redirect_to auth_login_path, alert: "Please start the verification process again"
      return
    end

    user = User.find_by(email: email)

    if user
      auth_service = AuthenticationService.new(user: user, purpose: purpose, request: request)
      auth_service.send_verification!
      redirect_to auth_new_otp_verification_path, notice: "Verification code resent. Check your email."
    else
      redirect_to auth_login_path, alert: "User not found. Please start again."
    end
  end

  # DELETE /auth/logout
  def destroy
    session.delete(:user_id)
    reset_session
    redirect_to auth_login_path, notice: "Logged out successfully"
  end

  private

  def require_unauthenticated
    if current_user
      redirect_to root_path, notice: "You are already logged in"
    end
  end
end
