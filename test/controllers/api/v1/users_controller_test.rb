require "test_helper"


class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::Assertions

  # == Setup ==

  setup do
    @user = users(:one)
    @user_two = users(:two)
    login_as(@user)
  end

  # == Helper Methods ==

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

  # == Tests ==
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
    assert_no_difference("User.count") do
      assert_changes -> { @user.reload.email }, from: @user.email, to: user_params(:updated)[:email] do
        put api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'User updated successfully', json_body['message']
  end

  test 'update user password with valid params' do
    assert_no_difference("User.count") do
      assert_changes -> { @user.reload.password_digest } do
        put api_v1_user_url(@user), headers: authenticated_header, params:
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
    assert_no_difference("User.count") do
      assert_changes -> { [@user.reload.email, @user.password_digest] } do
        put api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'User updated successfully', json_body['message']
  end

  test 'should not update user email with invalid params' do
    assert_no_difference("User.count") do
      assert_no_changes -> { @user.reload.email } do
        put api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:invalid_email) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Email is invalid'
  end

  test 'should not update user password with invalid params' do
    assert_no_difference("User.count") do
      assert_no_changes -> { @user.reload.password_digest } do
        put api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:invalid_password) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Password can't be blank"
  end

  test 'should not update user with mismatched passwords' do
    assert_no_difference("User.count") do
      assert_no_changes -> { @user.reload.password_digest } do
        put api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:mismatch_password) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Password confirmation doesn't match Password"
  end

  test 'should not update user email and password with invalid params' do
    assert_no_difference("User.count") do
      assert_no_changes -> { [@user.reload.email, @user.password_digest] } do
        put api_v1_user_url(@user), headers: authenticated_header, params: { user: user_params(:invalid) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Email is invalid'
    assert_includes error_details, 'Password is too short (minimum is 6 characters)'
  end

  test 'should not update user with invalid token' do
    assert_no_difference("User.count") do
      assert_no_changes -> { [@user.reload] } do
        put api_v1_user_url(@user), headers: invalid_header, params: { user: user_params(:valid) }
      end
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not update user with missing token' do
    assert_no_difference("User.count") do
      assert_no_changes -> { [@user.reload] } do
        put api_v1_user_url(@user), headers: { }, params: { user: user_params(:valid) }
      end
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'should delete user with valid token' do
    assert_difference('User.count', -1) do
      delete api_v1_user_url(@user), headers: authenticated_header
    end
    assert_response :success
    assert_equal "User deleted successfully", json_body['message']
  end

  test 'should not destroy user with invalid token' do
    assert_no_difference('User.count') do
      delete api_v1_user_url(@user), headers: invalid_header
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not destroy user with missing token' do
    assert_no_difference('User.count') do
      delete api_v1_user_url(@user), headers: {  }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'fetch user data with valid token' do
    get api_v1_users_data_url(id: @user.id), headers: authenticated_header
    assert_response :success
    assert_equal @user.email, json_body['data']['attributes']['email']
  end

  test 'should not fetch user data with invalid token' do
    get api_v1_users_data_url(@user), headers: invalid_header
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not fetch user data with missing token' do
    get api_v1_users_data_url(@user), headers: {  }
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'fetch response shows correct data' do
    get api_v1_users_data_url, headers: authenticated_header
    assert_response :success
    expected_response = {
      "data" => {
        "id" => @user.id.to_s,
        "type" => "user",
        "attributes" => {
          "email" => @user.email,
          "created_at" => @user.created_at.iso8601(3),
          "updated_at" => @user.updated_at.iso8601(3),
          "articles_count" => @user.articles.count
        }
      }
    }
    assert_equal expected_response, json_body
  end

  test 'should not return index' do
    get '/api/v1/users'
    assert_response :not_found
  end
end
