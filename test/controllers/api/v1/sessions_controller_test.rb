require 'test_helper'

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  # == Setup ==

  def setup
    @user = User.create(email: "userone@example.com", password: "password123", password_confirmation: "password123")
    @session = Session.new(user: @user)
  end

  # == Helper Methods ==

  def logout(token)
    delete api_v1_logout_url, headers: { 'Authorization': "Bearer #{token}" }
  end

  # == Tests ==

  test 'valid user and session created in setup' do
    assert @user.valid?, 'User should be valid'
    assert @session.valid?, 'Session should be valid'
  end

  test 'should create session with valid login' do
    assert_difference("Session.count", 1) do
      post api_v1_login_url, params: { email: @user.email, password: 'password123' }
    end
    assert_response :success
    assert_not_nil @user.session
    assert_equal 'Successfully logged in', json_body['message']
  end

  test 'should not create session with invalid email' do
    assert_no_difference("Session.count") do
      post api_v1_login_url, params: { email: 'Invalid@email.com', password: 'password123' }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Invalid email or password'
  end

  test 'should not create session with invalid password' do
    assert_no_difference("Session.count") do
      post api_v1_login_url, params: { email: @user.email, password: "invalid_password" }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Invalid email or password'
  end

  test 'should logout with valid token' do
    login_as(@user)
    assert_difference("Session.count", -1) do
      delete api_v1_logout_url, headers: authenticated_header
    end
    assert_response :success
    assert_equal 'Logged out successfully', json_body['message']
  end

  test 'should not logout with invalid token' do
    login_as(@user)
    assert_no_difference("Session.count") do
      delete api_v1_logout_url, headers: { 'Authorization': 'Bearer invalid_token' }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not logout with missing token' do
    login_as(@user)
    assert_no_difference("Session.count") do
      delete api_v1_logout_url, headers: { }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'session should be created when user is created' do
    assert_difference("Session.count", 1) do
      post api_v1_users_url, params: { user: { email: 'valid@example.com', password: 'password123', password_confirmation: 'password123' } }
    end
    assert :success
    assert_equal "User created successfully", json_body['message']
  end

  test 'session should be not be created when user not is created' do
    assert_no_difference("Session.count") do
      post api_v1_users_url, params: { user: { email: '', password: 'password123', password_confirmation: 'password123' } }
    end
    assert :unprocessable_entity
    assert_includes error_details, 'Email is invalid'
  end
end
