# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    if current_user&.user_token&.expires_at&.< Time.current
      current_user.user_token.destroy
      current_user.session.destroy
      render json: { error: 'Token expired' }, status: :unauthorized
    elsif current_user.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_user
    @current_user = UserToken.find_by(token: token)&.user
  end

  def token
    auth_header = request.headers['Authorization']
    if auth_header.present? && auth_header.starts_with?("Bearer")
      @token = auth_header.split(" ").last
    end
  end
end
