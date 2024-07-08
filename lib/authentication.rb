module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    rescue_from Authentication::MissingTokenError, with: :handle_missing_token_error
    rescue_from Authentication::InvalidTokenError, with: :handle_invalid_token_error
    rescue_from Authentication::ExpiredTokenError, with: :handle_expired_token_error
  end

  private

  BEARER_PATTERN = /\ABearer .+\z/

  def authenticate_request
    token = extract_token
    raise MissingTokenError if token.nil?
    user_token = find_user_token(token)
    raise InvalidTokenError unless user_token
    raise ExpiredTokenError if user_token.expires_at < Time.current
    @current_user = user_token.user
  end

  def extract_token
    auth_header = request.headers['Authorization']
    raise MissingTokenError unless auth_header.present?
    raise InvalidTokenError unless auth_header.match?(BEARER_PATTERN)
    auth_header.split(" ").last
  end

  def find_user_token(token)
    decrypted_data = UserToken.decode(token)
    user_id = decrypted_data[:user_id] if decrypted_data
    UserToken.find_by(user_id: user_id, token: token)
  end

  def handle_missing_token_error(error)
    render json: { errors: [ErrorFormatter.missing_token_error(error)] }, status: :bad_request
  end

  def handle_invalid_token_error(error)
    render json: { errors: [ErrorFormatter.invalid_token_error(error)] }, status: :unauthorized
  end

  def handle_expired_token_error(error)
    render json: { errors: [ErrorFormatter.expired_token_error(error)] }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  class MissingTokenError < StandardError; end
  class InvalidTokenError < StandardError; end
  class ExpiredTokenError < StandardError; end
end
