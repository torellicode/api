module Api
  module V1
    class UsersController < ApplicationController
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TranslationHelper

      skip_before_action :authenticate_request, only: [:create]

      def create
        user = User.new(user_params)
        if user.save
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
          raise CustomError.new(pointer: 'user', code: 'validation_error', message: user.errors.full_messages.join(', '))
        end
      end

      def update
        if current_user.update(user_params)
          render json: current_user_serializer, status: :ok
        else
          raise CustomError.new(pointer: 'user', code: 'validation_error', message: current_user.errors.full_messages.join(', '))
        end
      end

      def destroy
        if current_user.destroy
          render json: { message: 'User deleted successfully' }, status: :ok
        else
          raise CustomError.new(pointer: 'user', code: 'deletion_error', message: current_user.errors.full_messages.join(', '))
        end
      end

      def data
        render json: current_user_serializer, status: :ok
      rescue ActiveRecord::RecordNotFound => e
        record_not_found(e)
      rescue StandardError => e
        internal_server_error(e)
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def current_user_serializer
        UserSerializer.new(current_user).serializable_hash
      end
    end
  end
end