class ApplicationController < ActionController::API
  include Authentication
  include ErrorHandling

  before_action :authenticate_request

  private

  def create_token_and_session(user)
    user.create_user_token!
    user.create_session!
  end

  def destroy_token_and_session(user)
    user.session&.destroy!
    user.user_token&.destroy!
  end
end
