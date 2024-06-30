# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authenticate_request, only: [:create]

      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          user.user_token&.destroy
          user.session&.destroy

          user_token = user.create_user_token
          session = user.create_session

          render json: UserSerializer.new(user).serializable_hash.merge(token: { token: user_token.token, expires_at: user.user_token.expires_at }), status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def destroy
        encrypted_token = request.headers['Authorization'].split(" ").last
        user_token = UserToken.find_by(token: encrypted_token)

        if user_token
          user_token.destroy
          user_token.user.session.destroy
          render json: { message: 'Logged out successfully' }
        else
          render json: { error: 'Invalid token' }, status: :unauthorized
        end
      end
    end
  end
end