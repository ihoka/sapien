# Authentication System Specification

**Feature:** User Registration and Authentication
**Version:** 1.0
**Date:** 2025-10-28
**Status:** Draft

## Overview

Implement a passwordless authentication system for Sapien using magic links for initial signup/login and 6-digit OTP codes for verification. This provides a secure, user-friendly authentication experience without password management complexity.

## User Stories

### As a new user:
- I want to sign up using only my email address
- I want to receive a magic link to verify my email and complete registration
- I want to be automatically logged in when I click the magic link
- I want to enter a 6-digit OTP code as an alternative verification method

### As a returning user:
- I want to log in using only my email address
- I want to receive a magic link to log in without a password
- I want to enter a 6-digit OTP code as an alternative login method
- I want my session to persist across browser sessions

### As a system administrator:
- I want magic links to expire after a reasonable time period
- I want OTP codes to expire after a short time period
- I want to prevent brute force attacks on OTP verification
- I want to track failed authentication attempts

## Technical Requirements

### Core Models

#### User Model
```ruby
class User < ApplicationRecord
  # Attributes
  - email:string (required, unique, indexed)
  - email_confirmed:boolean (default: false)
  - email_confirmed_at:datetime
  - current_sign_in_at:datetime
  - last_sign_in_at:datetime
  - sign_in_count:integer (default: 0)
  - created_at:datetime
  - updated_at:datetime

  # Validations
  - validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  - normalizes :email, with: ->(email) { email.strip.downcase }

  # Methods
  - confirmed? -> boolean
  - confirm_email! -> void
  - record_sign_in! -> void
end
```

#### MagicLink Model
```ruby
class MagicLink < ApplicationRecord
  # Associations
  - belongs_to :user

  # Attributes
  - token:string (required, unique, indexed)
  - purpose:string (required) # "signup" or "login"
  - expires_at:datetime (required)
  - used_at:datetime
  - ip_address:string
  - user_agent:string

  # Validations
  - validates :token, presence: true, uniqueness: true
  - validates :purpose, presence: true, inclusion: { in: %w[signup login] }
  - validates :expires_at, presence: true

  # Scopes
  - scope :valid, -> { where(used_at: nil).where("expires_at > ?", Time.current) }
  - scope :expired, -> { where("expires_at <= ?", Time.current) }
  - scope :used, -> { where.not(used_at: nil) }

  # Methods
  - valid? -> boolean (not used and not expired)
  - expired? -> boolean
  - used? -> boolean
  - mark_as_used! -> void
  - self.generate_token -> string (secure random token)
end
```

#### OtpCode Model
```ruby
class OtpCode < ApplicationRecord
  # Associations
  - belongs_to :user

  # Attributes
  - code:string (required, 6 digits)
  - purpose:string (required) # "signup" or "login"
  - expires_at:datetime (required)
  - verified_at:datetime
  - attempts:integer (default: 0)
  - max_attempts:integer (default: 3)
  - ip_address:string
  - user_agent:string

  # Validations
  - validates :code, presence: true, format: { with: /\A\d{6}\z/ }
  - validates :purpose, presence: true, inclusion: { in: %w[signup login] }
  - validates :expires_at, presence: true

  # Scopes
  - scope :valid, -> { where(verified_at: nil).where("expires_at > ?", Time.current).where("attempts < max_attempts") }
  - scope :expired, -> { where("expires_at <= ?", Time.current) }
  - scope :verified, -> { where.not(verified_at: nil) }

  # Methods
  - valid? -> boolean (not verified, not expired, attempts < max_attempts)
  - expired? -> boolean
  - verified? -> boolean
  - max_attempts_reached? -> boolean
  - increment_attempts! -> void
  - verify! -> boolean
  - self.generate_code -> string (6-digit random number)
end
```

### Authentication Flow

#### Signup Flow

**Step 1: User submits email**
```
POST /auth/signup
Params: { email: "user@example.com" }

Process:
1. Validate email format
2. Check if user already exists
   - If exists and confirmed: redirect to login
   - If exists and not confirmed: resend verification
   - If new: create user record
3. Generate magic link token (expires in 1 hour)
4. Generate OTP code (expires in 10 minutes)
5. Send email with both magic link and OTP code
6. Redirect to verification page

Response:
- Success: 200 OK, { message: "Check your email for verification link and code" }
- Invalid email: 422 Unprocessable Entity, { error: "Invalid email format" }
- Server error: 500 Internal Server Error
```

**Step 2a: User clicks magic link**
```
GET /auth/verify/:token

Process:
1. Find magic link by token
2. Validate:
   - Token exists
   - Not already used
   - Not expired
   - Purpose is "signup"
3. Mark magic link as used
4. Confirm user email
5. Create session
6. Redirect to dashboard

Response:
- Success: Redirect to dashboard with flash notice
- Invalid/expired: Redirect to signup with flash alert
```

**Step 2b: User enters OTP code**
```
POST /auth/verify_otp
Params: { email: "user@example.com", code: "123456" }

Process:
1. Find user by email
2. Find valid OTP code for user
3. Validate:
   - Code matches
   - Not expired
   - Attempts < max_attempts
4. If invalid:
   - Increment attempts
   - Return error
   - Lock out after max attempts
5. If valid:
   - Mark OTP as verified
   - Confirm user email
   - Create session
   - Redirect to dashboard

Response:
- Success: 200 OK, redirect to dashboard
- Invalid code: 422 Unprocessable Entity, { error: "Invalid code", attempts_remaining: 2 }
- Max attempts: 422 Unprocessable Entity, { error: "Too many attempts. Request a new code." }
- Expired: 422 Unprocessable Entity, { error: "Code expired. Request a new code." }
```

#### Login Flow

**Step 1: User submits email**
```
POST /auth/login
Params: { email: "user@example.com" }

Process:
1. Validate email format
2. Find user by email
   - If not found: return generic "check email" message (prevent enumeration)
   - If found but not confirmed: resend verification email
   - If found and confirmed: proceed
3. Generate magic link token (expires in 1 hour)
4. Generate OTP code (expires in 10 minutes)
5. Send email with both magic link and OTP code
6. Redirect to verification page

Response:
- Always return: 200 OK, { message: "Check your email for login link and code" }
```

**Step 2a: User clicks magic link**
```
GET /auth/verify/:token

Process:
1. Find magic link by token
2. Validate:
   - Token exists
   - Not already used
   - Not expired
   - Purpose is "login"
3. Mark magic link as used
4. Create session
5. Record sign-in timestamp
6. Redirect to dashboard

Response:
- Success: Redirect to dashboard with flash notice
- Invalid/expired: Redirect to login with flash alert
```

**Step 2b: User enters OTP code**
```
POST /auth/verify_otp
Params: { email: "user@example.com", code: "123456" }

Process:
1. Find user by email
2. Find valid OTP code for user
3. Validate:
   - Code matches
   - Not expired
   - Attempts < max_attempts
4. If invalid:
   - Increment attempts
   - Return error
5. If valid:
   - Mark OTP as verified
   - Create session
   - Record sign-in timestamp
   - Redirect to dashboard

Response:
- Success: 200 OK, redirect to dashboard
- Invalid code: 422 Unprocessable Entity, { error: "Invalid code", attempts_remaining: 2 }
- Max attempts: 422 Unprocessable Entity, { error: "Too many attempts. Request a new code." }
- Expired: 422 Unprocessable Entity, { error: "Code expired. Request a new code." }
```

#### Logout Flow

```
DELETE /auth/logout

Process:
1. Destroy current session
2. Clear session cookie
3. Redirect to login page

Response:
- Success: Redirect to login with flash notice
```

### Controllers

#### AuthController
```ruby
class AuthController < ApplicationController
  # Actions
  - new_signup (GET /auth/signup) - Show signup form
  - create_signup (POST /auth/signup) - Process signup request
  - new_login (GET /auth/login) - Show login form
  - create_login (POST /auth/login) - Process login request
  - verify (GET /auth/verify/:token) - Verify magic link token
  - new_otp_verification (GET /auth/verify_otp) - Show OTP entry form
  - verify_otp (POST /auth/verify_otp) - Verify OTP code
  - resend (POST /auth/resend) - Resend verification email
  - destroy (DELETE /auth/logout) - Logout user

  # Before actions
  - require_unauthenticated (only: [:new_signup, :create_signup, :new_login, :create_login])
  - require_authenticated (only: [:destroy])
end
```

### Services

#### AuthenticationService
```ruby
class AuthenticationService
  # Methods
  - initialize(user:, purpose:, request:)
  - send_verification! -> void
    - Generate magic link and OTP
    - Send email with both verification methods
    - Log authentication attempt
  - verify_magic_link(token:) -> User | nil
  - verify_otp(email:, code:) -> User | nil
  - create_session(user:) -> Session
end
```

#### MagicLinkService
```ruby
class MagicLinkService
  # Methods
  - self.generate(user:, purpose:, request:) -> MagicLink
  - self.verify(token:) -> MagicLink | nil
  - self.cleanup_expired -> integer (number of records deleted)
end
```

#### OtpService
```ruby
class OtpService
  # Methods
  - self.generate(user:, purpose:, request:) -> OtpCode
  - self.verify(email:, code:) -> OtpCode | nil
  - self.cleanup_expired -> integer (number of records deleted)
end
```

### Mailers

#### AuthMailer
```ruby
class AuthMailer < ApplicationMailer
  # Methods
  - signup_verification(user:, magic_link:, otp_code:)
    - Subject: "Verify your Sapien account"
    - Body: Magic link button + OTP code
  - login_verification(user:, magic_link:, otp_code:)
    - Subject: "Log in to Sapien"
    - Body: Magic link button + OTP code
end
```

### Background Jobs

#### CleanupExpiredTokensJob
```ruby
class CleanupExpiredTokensJob < ApplicationJob
  queue_as :default

  # Run daily to clean up expired magic links and OTP codes
  def perform
    MagicLinkService.cleanup_expired
    OtpService.cleanup_expired
  end
end
```

### Views

#### Signup Flow
- `auth/new_signup.html.erb` - Email entry form
- `auth/verify_otp.html.erb` - OTP code entry form

#### Login Flow
- `auth/new_login.html.erb` - Email entry form
- `auth/verify_otp.html.erb` - OTP code entry form (shared with signup)

#### Mailer Templates
- `auth_mailer/signup_verification.html.erb` - Signup verification email
- `auth_mailer/signup_verification.text.erb` - Plain text version
- `auth_mailer/login_verification.html.erb` - Login verification email
- `auth_mailer/login_verification.text.erb` - Plain text version

### Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Authentication
  namespace :auth do
    # Signup
    get "signup", to: "auth#new_signup", as: :signup
    post "signup", to: "auth#create_signup"

    # Login
    get "login", to: "auth#new_login", as: :login
    post "login", to: "auth#create_login"

    # Verification
    get "verify/:token", to: "auth#verify", as: :verify
    get "verify_otp", to: "auth#new_otp_verification", as: :new_otp_verification
    post "verify_otp", to: "auth#verify_otp", as: :verify_otp

    # Resend
    post "resend", to: "auth#resend", as: :resend

    # Logout
    delete "logout", to: "auth#destroy", as: :logout
  end

  # Root
  root "dashboard#index"
end
```

## Security Considerations

### Token Generation
- Magic link tokens: Use `SecureRandom.urlsafe_base64(32)` for 256-bit entropy
- OTP codes: Use `SecureRandom.random_number(1000000).to_s.rjust(6, "0")` for 6 digits
- Store tokens with index for fast lookup
- Use constant-time comparison for token validation

### Rate Limiting
- Limit signup/login requests: 5 per email per hour
- Limit OTP verification attempts: 3 per code
- Limit magic link generation: 3 per email per hour
- Implement IP-based rate limiting for additional protection

### Expiration Times
- Magic links: 1 hour expiration
- OTP codes: 10 minutes expiration
- Session duration: 2 weeks (configurable)
- Remember me: 30 days (future feature)

### Email Enumeration Prevention
- Always return same message for signup/login regardless of user existence
- Use generic error messages ("Check your email")
- Don't reveal if email exists in system

### Session Management
- Use Rails encrypted cookies for session storage
- Set secure and httponly flags on session cookies
- Regenerate session ID after authentication
- Clear sensitive data from session on logout

### Brute Force Protection
- Limit OTP attempts to 3 per code
- Lock out user after max attempts
- Require new code generation after lockout
- Track failed authentication attempts
- Consider temporary account lockout after multiple failed codes

### Email Security
- Use SPF, DKIM, and DMARC for email authentication
- Include unsubscribe link in all emails
- Log all email sending for audit trail
- Implement email delivery monitoring

## Database Migrations

### Create Users Table
```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.boolean :email_confirmed, default: false, null: false
      t.datetime :email_confirmed_at
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.integer :sign_in_count, default: 0, null: false

      t.timestamps
    end
  end
end
```

### Create Magic Links Table
```ruby
class CreateMagicLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_links do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false, index: { unique: true }
      t.string :purpose, null: false
      t.datetime :expires_at, null: false, index: true
      t.datetime :used_at
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :magic_links, [:user_id, :purpose, :expires_at]
  end
end
```

### Create OTP Codes Table
```ruby
class CreateOtpCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :otp_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code, null: false
      t.string :purpose, null: false
      t.datetime :expires_at, null: false, index: true
      t.datetime :verified_at
      t.integer :attempts, default: 0, null: false
      t.integer :max_attempts, default: 3, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :otp_codes, [:user_id, :code, :purpose]
    add_index :otp_codes, [:user_id, :purpose, :expires_at]
  end
end
```

## Testing Requirements

### Model Tests
- User validations (email format, uniqueness, presence)
- MagicLink validations and scopes
- OtpCode validations and scopes
- Token generation uniqueness
- Expiration logic
- State transitions (unused → used, unverified → verified)

### Controller Tests
- Signup flow (happy path and error cases)
- Login flow (happy path and error cases)
- Magic link verification
- OTP verification
- Logout functionality
- Unauthenticated access protection
- Authenticated access protection

### Service Tests
- AuthenticationService full flows
- MagicLinkService generation and verification
- OtpService generation and verification
- Cleanup expired tokens

### Integration Tests
- Full signup flow (email → magic link → dashboard)
- Full signup flow (email → OTP → dashboard)
- Full login flow (email → magic link → dashboard)
- Full login flow (email → OTP → dashboard)
- Expired token handling
- Invalid token handling
- Rate limiting
- Session persistence

### System Tests (Capybara)
- User signs up with magic link
- User signs up with OTP code
- User logs in with magic link
- User logs in with OTP code
- User enters invalid OTP code
- User exceeds max OTP attempts
- User logs out

### Mailer Tests
- Signup verification email content
- Login verification email content
- Email delivery
- Email formatting (HTML and text)

### Security Tests
- Token uniqueness and randomness
- Constant-time token comparison
- Rate limiting enforcement
- Brute force protection
- Email enumeration prevention
- Session security

## Email Templates

### Signup Verification Email
```
Subject: Verify your Sapien account

Hi there!

Thanks for signing up for Sapien. Click the button below to verify your email and get started:

[Verify Email Button] (magic link)

Or enter this 6-digit code: 123456

This code expires in 10 minutes.

If you didn't sign up for Sapien, you can safely ignore this email.

---
Sapien Team
```

### Login Verification Email
```
Subject: Log in to Sapien

Hi there!

Click the button below to log in to your Sapien account:

[Log In Button] (magic link)

Or enter this 6-digit code: 123456

This code expires in 10 minutes.

If you didn't request this login, please ignore this email.

---
Sapien Team
```

## UI/UX Requirements

### Signup Form
- Clean, minimal design
- Email input with validation
- Clear call-to-action button
- Link to login page
- Success message after submission
- Error handling with helpful messages

### Login Form
- Clean, minimal design
- Email input with validation
- Clear call-to-action button
- Link to signup page
- Success message after submission
- Error handling with helpful messages

### OTP Verification Form
- 6-digit code input (numeric only)
- Auto-focus on input field
- Remaining attempts indicator
- Resend code button
- Clear error messages
- Success feedback
- Countdown timer for expiration

### Email Design
- Responsive HTML email template
- Clear, prominent CTA button
- OTP code in large, easy-to-read font
- Plain text fallback
- Brand colors and logo
- Footer with unsubscribe link

## Accessibility Requirements

- Semantic HTML with proper heading hierarchy
- ARIA labels for form inputs
- Keyboard navigation support
- Screen reader friendly error messages
- Focus management after form submission
- High contrast text and buttons
- Responsive design for mobile devices

## Performance Requirements

- Email delivery within 30 seconds
- Magic link verification < 200ms
- OTP verification < 200ms
- Session creation < 100ms
- Database queries optimized with proper indexes
- Background job for token cleanup (run daily)

## Monitoring & Logging

### Metrics to Track
- Signup attempts (successful/failed)
- Login attempts (successful/failed)
- Magic link usage vs OTP usage
- Email delivery success rate
- Token expiration rate (before use)
- Average verification time
- Failed OTP attempts
- Rate limit violations

### Logging Requirements
- Log all authentication attempts with IP and user agent
- Log email sending (success/failure)
- Log magic link and OTP generation
- Log verification attempts
- Log session creation and destruction
- Log rate limit violations
- Use structured logging (JSON format)

## Future Enhancements (Out of Scope)

- OAuth social login (Google, GitHub, etc.)
- Two-factor authentication (TOTP)
- Remember me functionality
- Trusted device tracking
- Email change verification
- Account deletion
- User profile management
- Password fallback option
- Biometric authentication (WebAuthn)

## Dependencies

### Gems
- `rails` (8.1.0) - Framework
- `sqlite3` - Database
- No additional authentication gems (implement from scratch)

### Rails Features Used
- ActiveMailer for email sending
- ActiveJob with Solid Queue for background jobs
- ActiveRecord for database operations
- ActionController for request handling
- ActionView for templates

## Configuration

### Email Configuration
```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_url_options = { host: ENV["APP_HOST"] }
config.action_mailer.smtp_settings = {
  address: ENV["SMTP_ADDRESS"],
  port: ENV["SMTP_PORT"],
  domain: ENV["SMTP_DOMAIN"],
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"],
  authentication: :plain,
  enable_starttls_auto: true
}
```

### Session Configuration
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: "_sapien_session",
  expire_after: 2.weeks,
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
```

### Rate Limiting Configuration
```ruby
# config/initializers/rate_limiting.rb
# Using Rack::Attack or custom implementation
Rack::Attack.throttle("auth/signup", limit: 5, period: 1.hour) do |req|
  req.params["email"] if req.path == "/auth/signup" && req.post?
end

Rack::Attack.throttle("auth/login", limit: 5, period: 1.hour) do |req|
  req.params["email"] if req.path == "/auth/login" && req.post?
end

Rack::Attack.throttle("auth/verify_otp", limit: 10, period: 1.hour) do |req|
  req.params["email"] if req.path == "/auth/verify_otp" && req.post?
end
```

## Acceptance Criteria

### Signup Flow
- ✅ User can enter email address
- ✅ System validates email format
- ✅ System creates user record
- ✅ System sends verification email with magic link and OTP
- ✅ User receives email within 30 seconds
- ✅ User can click magic link to verify and login
- ✅ User can enter OTP code to verify and login
- ✅ Magic link expires after 1 hour
- ✅ OTP code expires after 10 minutes
- ✅ User is redirected to dashboard after verification
- ✅ Invalid/expired tokens show appropriate error messages

### Login Flow
- ✅ User can enter email address
- ✅ System validates email format
- ✅ System sends login email with magic link and OTP
- ✅ User receives email within 30 seconds
- ✅ User can click magic link to login
- ✅ User can enter OTP code to login
- ✅ Magic link expires after 1 hour
- ✅ OTP code expires after 10 minutes
- ✅ User is redirected to dashboard after login
- ✅ Session persists across browser sessions
- ✅ Invalid/expired tokens show appropriate error messages

### Security
- ✅ Tokens are cryptographically secure
- ✅ Tokens are single-use only
- ✅ OTP attempts are limited to 3 per code
- ✅ Rate limiting prevents brute force
- ✅ Email enumeration is prevented
- ✅ Sessions are secure with httponly and secure flags
- ✅ Expired tokens are cleaned up daily

### User Experience
- ✅ Forms are simple and intuitive
- ✅ Error messages are helpful and clear
- ✅ Success messages provide clear next steps
- ✅ Email templates are professional and branded
- ✅ OTP input is user-friendly (numeric only, auto-focus)
- ✅ Countdown timer shows OTP expiration
- ✅ Resend code option is available

### Testing
- ✅ All models have comprehensive unit tests
- ✅ All controllers have comprehensive tests
- ✅ All services have comprehensive tests
- ✅ Integration tests cover full flows
- ✅ System tests validate UI interactions
- ✅ Security features are tested
- ✅ Test coverage > 90%

---

**Next Steps:**
1. Review and approve specification
2. Create Rails models and migrations
3. Implement authentication services
4. Build controllers and views
5. Create email templates
6. Write comprehensive tests
7. Implement rate limiting
8. Add monitoring and logging
9. Deploy and monitor

**Estimated Development Time:** 16-24 hours
**Priority:** High (blocking other features)
