class TokenVerifierService
  def initialize(token, strict: false)
    @token = token
    @strict = strict
  end

  def verify
    decoded = JsonWebToken.decode(@token)

    return strict_fallback if @strict
    
    return decoded if decoded && decoded[:user_id]

    nil
  end

  private

  def strict_fallback
    response = Faraday.get("#{auth_service_url}/api/v1/verify_token") do |req|
      req.headers['Authorization'] = "Bearer #{@token}"
      req.headers['Content-Type'] = 'application/json'
    end

    if response.success?
      body = JSON.parse(response.body).with_indifferent_access
      { user_id: body[:user_id] }
    else
      Rails.logger.warn("Strict fallback failed with status #{response.status}: #{response.body}")
      nil
    end
  rescue => e
    Rails.logger.error("TokenVerifierService strict fallback error: #{e.message}")
    nil
  end

  def auth_service_url
    ENV.fetch("AUTH_SERVICE_URL", "http://localhost:3000")
  end
end
