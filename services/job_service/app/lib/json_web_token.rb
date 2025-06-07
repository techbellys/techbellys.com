class JsonWebToken
  SECRET_KEY = ENV['JWT_SECRET'] || Rails.application.credentials.jwt_secret

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end
