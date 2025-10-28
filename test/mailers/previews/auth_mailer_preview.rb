# Preview all emails at http://localhost:3000/rails/mailers/auth_mailer
class AuthMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/auth_mailer/signup_verification
  def signup_verification
    AuthMailer.signup_verification
  end

  # Preview this email at http://localhost:3000/rails/mailers/auth_mailer/login_verification
  def login_verification
    AuthMailer.login_verification
  end
end
