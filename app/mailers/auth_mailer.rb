class AuthMailer < ApplicationMailer
  def signup_verification(user:, magic_link:, otp_code:)
    @user = user
    @magic_link = magic_link
    @otp_code = otp_code
    @verify_url = auth_verify_url(token: magic_link.token)

    mail(
      to: user.email,
      subject: "Verify your Sapien account"
    )
  end

  def login_verification(user:, magic_link:, otp_code:)
    @user = user
    @magic_link = magic_link
    @otp_code = otp_code
    @verify_url = auth_verify_url(token: magic_link.token)

    mail(
      to: user.email,
      subject: "Log in to Sapien"
    )
  end
end
