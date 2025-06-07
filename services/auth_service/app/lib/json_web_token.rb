class JsonWebToken
  SECRET_KEY = ENV['JWT_SECRET'] || Rails.application.credentials.jwt_secret

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    raise e
  end

  def self.generate_refresh_token
    SecureRandom.hex(64)
  end
end

