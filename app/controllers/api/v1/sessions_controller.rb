module Api
  module V1
    class SessionsController < ApplicationController
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TranslationHelper

      skip_before_action :authenticate_request, only: [:create]

      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          destroy_token_and_session(user)
          create_token_and_session(user)

          render json: { message: 'Successfully logged in' }.merge(sessions_created_response(user)), status: :ok
        else
          render json: { errors: [ErrorFormatter.invalid_login_error] }, status: :unprocessable_entity
        end
      end

      def destroy
        user_token = UserToken.find_by(token: extract_token)

        if user_token
          user = User.find_by(id: user_token.user_id)
          destroy_token_and_session(user) if user
          render json: { message: 'Logged out successfully' }, status: :ok
        else
          render json: { errors: [ErrorFormatter.invalid_token_error(InvalidTokenError.new("Invalid or expired token"))] }, status: :unprocessable_entity
        end
      end

      private

      def sessions_created_response(user)
        user_token = user.user_token
        UserSerializer.new(user).serializable_hash.tap do |hash|
          hash[:data].merge!(
            session: {
              expires_at: l(user_token.expires_at, format: :long)
            },
            token: user_token.token
          )
        end
      end
    end
  end
end
