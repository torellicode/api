module Api
  module V1
    class UserTokensController < ApplicationController
      def create
        user = User.find(params[:user_id])
        user.user_token&.destroy
        user_token = user.create_user_token

        if user_token.save
          render json: { token: user_token.token, expires_at: user_token.expires_at }, status: :ok
        else
          render json: { error: user_token.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        encrypted_token = params[:id]
        user_token = UserToken.find_by(token: encrypted_token)

        if user_token
          user_token.destroy
          render json: { message: 'Token destroyed successfully' }, status: :ok
        else
          render json: { error: 'Invalid Token' }, status: :not_found
        end
      end
    end
  end
end
