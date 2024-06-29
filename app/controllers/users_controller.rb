class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: %i[create]

  def create
    user = User.new(user_params)
    if user.save
      user_token = user.create_user_token
      session = user.create_session
      render json: {
        message: 'User created successfully',
        token: user_token.token
      }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if current_user.update(user_params)
      render json: { message: 'User updated successfully' }, status: :ok
    else
      render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user
      current_user.destroy
      render json: { message: 'User deleted successfully' }
    else
      render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def data
    render json: current_user
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
