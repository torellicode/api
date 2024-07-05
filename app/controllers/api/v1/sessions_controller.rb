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
          render json: format_errors('Invalid email or password'), status: :unprocessable_entity
        end
      end

      def destroy
        user_token = UserToken.find_by(token: token_from_header)

        if user_token
          destroy_token_and_session(User.find_by(user_token: user_token))
          render json: { message: 'Logged out successfully' }
        end
      end

      private

      def sessions_created_response(user)
        user_token = user.user_token
        UserSerializer.new(user).serializable_hash.tap { |hash|
          hash[:data].merge!(
            session: {
              expires_at: l(user_token.expires_at, format: :long)
            },
            token: user_token.token
          )
        }
      end
    end
  end
end