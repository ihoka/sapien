class CleanupExpiredTokensJob < ApplicationJob
  queue_as :default

  def perform
    magic_links_deleted = MagicLinkService.cleanup_expired
    otp_codes_deleted = OtpService.cleanup_expired

    Rails.logger.info("Cleaned up expired tokens: #{magic_links_deleted} magic links, #{otp_codes_deleted} OTP codes")
  end
end
