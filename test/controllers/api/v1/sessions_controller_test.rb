require 'test_helper'

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  # == Setup ==
  def setup
    @user = users(:one)
  end

  # == Helper Methods ==
  def login_as(user)
    post api_v1_login_url, params: { email: user.email, password: 'password123' }
    json_response = JSON.parse(response.body)
    @token = json_response['data']['token']
  end

  def logout(token)
    delete api_v1_logout_url, headers: { 'Authorization': "Bearer #{token}" }
  end

  # == Tests ==
  test 'should login with valid credentials' do
    assert_difference("Session.count", 1) do
      login_as(@user)
    end
    assert_response :success
    assert_not_nil @token
  end

  test 'should not login with invalid email' do
    assert_no_difference("Session.count") do
      post api_v1_login_url, params: { email: "Invalid@email.com", password: "password123" }
    end
    assert_response :unprocessable_entity
  end

  test 'should not login with invalid password' do
    assert_no_difference("Session.count") do
      post api_v1_login_url, params: { email: @user.email, password: "invalid_password" }
    end
    assert_response :unprocessable_entity
  end

  test 'should logout with valid token' do
    login_as(@user)
    assert_difference("Session.count", -1) do
      logout(@token)
    end
    assert_response :success
  end

  test 'should not logout with invalid token' do
    login_as(@user)
    assert_no_difference("Session.count") do
      logout("Invalid token")
    end
    assert_response :unauthorized
  end

  test 'should not logout with missing token' do
    login_as(@user)
    assert_no_difference("Session.count") do
      logout(nil)
    end
    assert_response :unauthorized
  end
end
