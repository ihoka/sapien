Rails.application.config.session_store :cookie_store,
  key: "_sapien_session",
  expire_after: 2.weeks,
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
