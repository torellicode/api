module Api
  module V1
    class SessionsController < ApplicationController
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TranslationHelper

      skip_before_action :authenticate_request, only: [:create]

      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          user.user_token&.destroy
          user.session&.destroy

          user_token = user.create_user_token
          user.create_session

          render json: UserSerializer.new(user).serializable_hash.tap { |hash|
            hash[:data].merge!(
              session: {
                expires_at: l(user_token.expires_at, format: :long)
              },
              token: user_token.token
            )
          }, status: :ok
        else
          render json: format_errors('Invalid email or password'), status: :unprocessable_entity
        end
      end

      def destroy
        auth_header = request.headers['Authorization']

        if auth_header.nil? || !auth_header.match(/^Bearer /)
          render json: format_errors('Token is missing or invalid'), status: :unauthorized
          return
        end

        encrypted_token = auth_header.split(" ").last
        user_token = UserToken.find_by(token: encrypted_token)

        if user_token
          user_token.destroy
          user_token.user.session.destroy
          render json: { message: 'Logged out successfully' }
        else
          render json: format_errors('Invalid token'), status: :unauthorized
        end
      end
    end
  end
end