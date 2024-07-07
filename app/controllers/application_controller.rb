class ApplicationController < ActionController::API
  include ErrorFormatter

  before_action :authenticate_request

  private

  BEARER_PATTERN = /\ABearer .+\z/
  TOKEN_PATTERN = /\A[\w\-]+\.\w+\.\w+\z/

  def authenticate_request
    token = extract_token
    raise Errors::MissingTokenError unless request.headers['Authorization'].present?
    raise Errors::InvalidTokenError unless token

    user_token = find_user_token(token)
    raise Errors::InvalidTokenError unless user_token
    raise Errors::ExpiredTokenError if user_token.expires_at < Time.current

    @current_user = user_token.user
  rescue Errors::MissingTokenError, Errors::InvalidTokenError, Errors::ExpiredTokenError => e
    handle_authentication_error(e)
  end

  def extract_token
    auth_header = request.headers['Authorization']
    return nil unless auth_header.present? && auth_header.match?(BEARER_PATTERN)
    auth_header.split(" ").last
  end

  def find_user_token(token)
    decrypted_data = UserToken.decode(token)
    user_id = decrypted_data[:user_id] if decrypted_data
    UserToken.find_by(user_id: user_id, token: token)
  end

  def handle_authentication_error(error)
    handle_generic_error(error)
  end

  def current_user
    @current_user
  end

  def create_token_and_session(user)
    user.create_user_token!
    user.create_session!
  end

  def destroy_token_and_session(user)
    user.session&.destroy!
    user.user_token&.destroy!
  end
end
