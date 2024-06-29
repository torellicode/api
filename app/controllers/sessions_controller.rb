class SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      user.user_token&.destroy
      user.session&.destroy

      user_token = user.create_user_token
      session = user.create_session

      render json: { message: 'Logged in successfully', token: user_token.token, session_id: session.session_id }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    user_token = UserToken.find_by(token: request.headers['Authorization'].split(" ").last)
    if user_token
      user_token.destroy
      user_token.user.session.destroy
      render json: { message: 'Logged out successfully' }
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
