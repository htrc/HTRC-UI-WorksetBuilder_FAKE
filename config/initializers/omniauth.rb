OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure do |env|
  [200, {}, [env['omniauth.error'].inspect]]
end
