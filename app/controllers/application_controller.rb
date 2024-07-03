class ApplicationController < ActionController::API
  include ErrorFormatter

  before_action :authenticate_request

  private

  def authenticate_request
    token = token_from_header
    raise Errors::MissingTokenError if token.nil?

    decrypted_data = UserToken.decode(token)
    user_id = decrypted_data[:user_id] if decrypted_data
    user_token = UserToken.find_by(user_id: user_id, token: token)

    raise Errors::InvalidTokenError if user_token.nil?
    raise Errors::ExpiredTokenError if user_token.expires_at < Time.current

    @current_user = user_token.user
  rescue Errors::MissingTokenError, Errors::InvalidTokenError, Errors::ExpiredTokenError => e
    handle_generic_error(e)
  end

  def token_from_header
    auth_header = request.headers['Authorization']
    auth_header.present? && auth_header.starts_with?("Bearer") ? auth_header.split(" ").last : nil
  end

  def current_user
    @current_user
  end

  def create_token_and_session(user)
    user.create_user_token!
    user.create_session!
  end
end
