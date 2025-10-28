class MagicLinkService
  def self.generate(user:, purpose:, request:)
    # Generate unique token
    token = loop do
      candidate = MagicLink.generate_token
      break candidate unless MagicLink.exists?(token: candidate)
    end

    # Create magic link with 1 hour expiration
    user.magic_links.create!(
      token: token,
      purpose: purpose,
      expires_at: 1.hour.from_now,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  def self.verify(token:)
    magic_link = MagicLink.valid.find_by(token: token)
    return nil unless magic_link

    magic_link
  end

  def self.cleanup_expired
    expired_count = MagicLink.expired.count
    MagicLink.expired.delete_all
    expired_count
  end
end
