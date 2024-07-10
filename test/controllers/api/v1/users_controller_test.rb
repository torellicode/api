require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  # == Setup ==

  setup do
    @user = User.create(email: "userone@example.com", password: "password123", password_confirmation: "password123")
    @user_two = User.create(email: "usertwo@example.com", password: "password123", password_confirmation: "password123")
  end

  # == Helper Methods ==

  def login_as(user)
    post api_v1_login_url, params: { email: user.email, password: 'password123' }
    @token = json_body['data']['token']
  end

  def authenticated_header
    { 'Authorization': "Bearer #{@token}" }
  end

  def user_params(type)
    case type
    when :valid
      { email: 'validuser@example.com', password: 'password123', password_confirmation: 'password123' }
    when :invalid
      { email: 'invalid', password: 'short', password_confirmation: 'short' }
    when :updated
      { email: 'updated@example.com', password: 'newpassword123', password_confirmation: 'newpassword123' }
    when :invalid_email
      { email: '', password: 'password123', password_confirmation: 'password123' }
    when :invalid_password
      { email: 'validuser@example.com', password: '', password_confirmation: '' }
    when :mismatch_password
      { email: 'validuser@example.com', password: 'password123', password_confirmation: 'PASSWORD123' }
    end
  end

  def json_body
    JSON.parse(response.body)
  end

  def error_details
    json_body['errors'].map { |error| error['detail'] }
  end

  # == Tests ==

  test 'valid users created in setup' do
    assert @user.valid?, 'User one should be valid'
    assert @user_two.valid?, 'User two should be valid'
  end

  test 'creates a user with valid params' do
    assert_difference("User.count", 1) do
      post api_v1_users_url, params: { user: user_params(:valid) }
    end
    assert_response :created
    assert_equal 'User created successfully', json_body['message']
  end

  test 'should not create a user with invalid email' do
    assert_no_difference("User.count") do
      post api_v1_users_url, params: { user: user_params(:invalid_email) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Email is invalid'
  end

  test 'should not create a user with invalid password' do
    assert_no_difference("User.count") do
      post api_v1_users_url, params: { user: user_params(:invalid_password) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Password can't be blank"
  end

  test 'should not create a user with mismatching password and confirmation' do
    assert_no_difference("User.count") do
      post api_v1_users_url, params: { user: user_params(:mismatch_password) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Password confirmation doesn't match Password"
  end

  test 'update user email with valid params' do
    login_as(@user)

    assert_no_difference("User.count") do
      assert_changes -> { @user.reload.email }, from: @user.email, to: user_params(:updated)[:email] do
        patch api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'User updated successfully', json_body['message']
  end

  test 'update user password with valid params' do
    login_as(@user)
    assert_no_difference("User.count") do
      assert_changes -> { @user.reload.password_digest } do
        patch api_v1_user_url(@user), headers: authenticated_header, params:
        { user:
          {
            password: user_params(:updated)[:password],
            password_confirmation: user_params(:updated)[:password_confirmation]
          }
        }
      end
    end
    assert_response :success
    assert_equal 'User updated successfully', json_body['message']
  end

  test 'update user email and password with valid params' do
    login_as(@user)
    assert_no_difference("User.count") do
      assert_changes -> { [@user.reload.email, @user.password_digest] } do
        patch api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'User updated successfully', json_body['message']
  end

  test 'should not update user email with invalid params' do
    login_as(@user)
    assert_no_difference("User.count") do
      assert_no_changes -> { @user.reload.email } do
        patch api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:invalid_email) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Email is invalid'
  end

  test 'should not update user password with invalid params' do
    login_as(@user)
    assert_no_difference("User.count") do
      assert_no_changes -> { @user.reload.password_digest } do
        patch api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:invalid_password) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Password can't be blank"
  end

  test 'should not update user with mismatched password' do
    login_as(@user)
    assert_no_difference("User.count") do
      assert_no_changes -> { @user.reload.password_digest } do
        patch api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:mismatch_password) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Password confirmation doesn't match Password"
  end

  test 'should not update user email and password with invalid params' do
    login_as(@user)
    assert_no_difference("User.count") do
      assert_no_changes -> { [@user.reload.email, @user.password_digest] } do
        patch api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:invalid) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Email is invalid'
    assert_includes error_details, 'Password is too short (minimum is 6 characters)'
  end

  test 'should delete user with valid token' do
    login_as(@user)
    assert_difference('User.count', -1) do
      delete api_v1_user_url(@user), headers: authenticated_header
    end
    assert_response :success
    assert_equal "User deleted successfully", json_body['message']
  end

  test 'should not destroy user with invalid token' do
    login_as(@user)
    assert_no_difference('User.count') do
      delete api_v1_user_url(@user), headers: { 'Authorization': 'Bearer invalid_token' }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should fetch user data with valid token' do
    login_as(@user)
    get api_v1_users_data_url(id: @user.id), headers: authenticated_header
    assert_response :success
    assert_equal @user.email, json_body['data']['attributes']['email']
  end

  test 'should not fetch user data with invalid token' do
    login_as(@user)
    get api_v1_users_data_url(@user), headers: { 'Authorization': 'Bearer invalid_token' }
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not return index' do
    get '/users'
    assert_response :not_found
  end
end
