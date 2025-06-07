class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login, :refresh]

  def register
    user = User.new(user_params)
    if user.save
      access_token = JsonWebToken.encode(user_id: user.id)
      refresh_token = JsonWebToken.generate_refresh_token
      RefreshTokenStore.set(user.id, refresh_token)
      render json: { access_token:,refresh_token:, user: user.as_json(except: [:password_digest]) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      access_token = JsonWebToken.encode(user_id: user.id)
      refresh_token = JsonWebToken.generate_refresh_token
      RefreshTokenStore.set(user.id, refresh_token)
      render json: { access_token:,refresh_token:, user: user.as_json(except: [:password_digest]) }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def profile
    render json: { user: current_user.as_json(except: [:password_digest]) }
  end

  def refresh
    user_id = params[:user_id].to_i
    refresh_token = params[:refresh_token]

    if RefreshTokenStore.valid?(user_id, refresh_token)
      new_access_token = JsonWebToken.encode(user_id: user_id)
      new_refresh_token = JsonWebToken.generate_refresh_token

      RefreshTokenStore.set(user_id, new_refresh_token)

      render json: {
        access_token: new_access_token,
        refresh_token: new_refresh_token
      }
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def verify
    token = request.headers['Authorization']&.split(' ')&.last
    decoded = JsonWebToken.decode(token)
    user = User.find(decoded[:user_id])

    render json: {
      user_id: user.id,
      email: user.email,
      valid: true
    }
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { valid: false, error: 'Invalid or expired token' }, status: :unauthorized
  end

  def logout
    user_id = current_user.id
    RefreshTokenStore.invalidate(user_id)
    head :ok
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end
end
