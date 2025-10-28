require "test_helper"

class AuthMailerTest < ActionMailer::TestCase
  test "signup_verification" do
    mail = AuthMailer.signup_verification
    assert_equal "Signup verification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "login_verification" do
    mail = AuthMailer.login_verification
    assert_equal "Login verification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
