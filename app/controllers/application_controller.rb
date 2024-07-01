class ApplicationController < ActionController::API
  include ErrorHandler
  
  before_action :authenticate_request

  private

  def authenticate_request
    token = token_from_header
    if token.nil?
      raise UnauthorizedError.new('Token is missing or invalid')
    end

    decrypted_data = UserToken.decode(token)
    user_id = decrypted_data[:user_id] if decrypted_data
    user_token = UserToken.find_by(user_id: user_id, token: token)

    if user_token.nil?
      raise UnauthorizedError.new('Invalid token')
    elsif user_token.expires_at < Time.current
      user_token.destroy
      user_token.user.session.destroy
      raise UnauthorizedError.new('Token expired')
    else
      @current_user = user_token.user
    end
  end

  def token_from_header
    auth_header = request.headers['Authorization']
    auth_header.present? && auth_header.starts_with?("Bearer") ? auth_header.split(" ").last : nil
  end

  def current_user
    @current_user
  end
end