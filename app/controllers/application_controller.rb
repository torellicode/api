class ApplicationController < ActionController::API
  include ErrorHandler
  
  before_action :authenticate_request

  private

  def authenticate_request
    decrypted_data = UserToken.decode(token_from_header)
    user_id = decrypted_data[:user_id] if decrypted_data
    user_token = UserToken.find_by(user_id: user_id, token: token_from_header)

    if user_token.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    elsif user_token.expires_at < Time.current
      user_token.destroy
      user_token.user.session.destroy
      render json: { error: 'Token expired' }, status: :unauthorized
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