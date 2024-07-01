require "test_helper"

class UserTest < ActiveSupport::TestCase
  # == Setup ==
  def setup
    @user = users(:one)
  end

  # == Helper Methods ==
  def valid_params
    { email: "validuser@example.com", password: "password123", password_confirmation: "password123" }
  end

  def invalid_params
    { email: "", password: "", password_confirmation: "" }
  end

  # == Tests ==
  test 'should be valid user fixture' do
    assert @user.valid?
  end

  test 'email should be present' do
    @user.email = nil
    assert_not @user.save
  end

  test 'email should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email.upcase
    assert_not duplicate_user.save
  end

  test 'password should be present' do
    @user.password = nil
    assert_not @user.save
  end

  test 'password should not be blank' do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test 'creates a user with valid params' do
    assert_difference("User.count", 1) do
      new_user = User.new(valid_params)
      new_user.save
    end
  end

  test 'does not create a user with invalid params' do
    assert_no_difference("User.count") do
      new_user = User.new(invalid_params)
      assert_not new_user.save
    end
  end

  test 'should update with valid params' do
    assert_no_difference("User.count", 1) do
      assert_changes -> { @user.reload.email }, from: @user.email, to: valid_params[:email] do
        assert @user.update(valid_params)
      end
    end
  end

  test 'should not update with invalid params' do
    assert_no_difference("User.count") do
      assert_not @user.update(invalid_params)
    end
  end

  test 'should delete user from database' do
    assert_difference("User.count", -1) do
      @user.destroy
    end
  end
end
