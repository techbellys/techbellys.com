module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request_by_default
    attr_reader :current_user_id
  end

  private

  def authenticate_request_by_default
    authenticate_request(strict: false)
  end

  def authenticate_request(strict: false)
    token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized('Missing token') unless token

    verifier = TokenVerifierService.new(token, strict: strict)
    decoded = verifier.verify

    if decoded && decoded[:user_id]
      @current_user_id = decoded[:user_id]
    else
      render_unauthorized('Invalid token')
    end
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: { error: message }, status: :unauthorized
  end
end
