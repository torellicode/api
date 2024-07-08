module Api
  module V1
    class UsersController < ApplicationController
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TranslationHelper

      skip_before_action :authenticate_request, only: [:create]
      before_action :set_user, only: [:update, :destroy]
      before_action :authorize_user, only: [:update, :destroy]

      def create
        user = User.new(user_params)
        if user.save
          create_token_and_session(user)
          render json: { message: 'User created successfully' }.merge(user_created_response(user)), status: :created
        else
          render json: { errors: ErrorFormatter.format_errors(user) }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: { message: 'User updated successfully' }.merge(current_user_serializer), status: :ok
        else
          render json: { errors: ErrorFormatter.format_errors(@user) }, status: :unprocessable_entity
        end
      end

      def destroy
        if @user.destroy
          destroy_token_and_session(@user)
          render json: { message: 'User deleted successfully' }, status: :ok
        else
          render json: { errors: ErrorFormatter.format_errors(@user) }, status: :unprocessable_entity
        end
      end

      def data
        if current_user.present?
          render json: current_user_serializer, status: :ok
        else
          render json: { errors: ErrorFormatter.record_not_found_error("User not found") }, status: :not_found
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def authorize_user
        render_unauthorized_error unless @user == current_user
      end

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

      def render_unauthorized_error
        render json: { errors: [ErrorFormatter.unauthorized_error(UnauthorizedError.new("You are not authorized to access this resource"))] }, status: :forbidden
      end
    end
  end
end
