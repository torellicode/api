require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  # == Setup ==

  setup do
    @user = users(:one)
  end

  # == Helper Methods ==

  def login_as(user)
    post api_v1_login_url, params: { email: user.email, password: 'password123' }
    json_response = JSON.parse(response.body)
    @token = json_response['data']['token']
  end

  def authenticated_header
    { 'Authorization': "Bearer #{@token}" }
  end

  def valid_params
    { email: "validuser@example.com", password: "password123", password_confirmation: "password123" }
  end

  def invalid_params
    { email: "", password: "", password_confirmation: "" }
  end

  # == Tests ==

  test 'valid user fixture' do
    assert @user.valid?
  end

  test 'should not return index' do
    get '/users'
    assert_response :not_found
  end

  test 'should fetch user data with valid token' do
    login_as(@user)
    get api_v1_data_url(id: @user.id), headers: authenticated_header
    assert_response :success
  end

  test 'should not fetch user data with invalid token' do
    login_as(@user)
    get api_v1_data_url(@user), headers: { 'Authorization': 'Bearer invalid-token' }
    assert_response :unauthorized
  end
end
