module Api
  module V1
    class UsersController < ApplicationController
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TranslationHelper

      skip_before_action :authenticate_request, only: [:create]

      def create
        user = User.new(user_params)
        if user.save!
          create_token_and_session(user)
          render json: user_created_response(user), status: :ok
        else
          render json: format_errors(user.errors), status: :unprocessable_entity
        end
      end

      def update
        if current_user.update!(user_params)
          render json: current_user_serializer, status: :ok
        else
          render json: format_errors(current_user.errors.full_messages), status: :unprocessable_entity
        end
      end

      def destroy
        if current_user.destroy!
          destroy_token_and_session(current_user)
          render json: { message: 'User deleted successfully' }, status: :ok
        else
          render json: format_errors('user', current_user.errors.full_messages, 422), status: :unprocessable_entity
        end
      end

      def data
        if current_user.present?
          render json: current_user_serializer, status: :ok
        else
          render json: format_errors('user', 'User not found', 404), status: :not_found
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def current_user_serializer
        UserSerializer.new(current_user).serializable_hash
      end

      def user_created_response(user)
        UserSerializer.new(user).serializable_hash.tap do |hash|
          hash[:data].merge!(
            session: {
              expires_at: l(user.user_token.expires_at, format: :long)
            },
            token: user.user_token.token
          )
        end
      end
    end
  end
end
