require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # == Setup ==

  setup do
    @user = User.new(email: "valid@example.com", password: "password123", password_confirmation: "password123")
  end

  # == Tests ==

  test 'valid users created in setup' do
    assert @user.valid?, 'User one should be valid'
  end

  test 'email should be present' do
    @user.email = nil
    assert_not @user.save, 'User saved without an email'
    assert_includes @user.errors[:email], "can't be blank", 'Email blank error not present'
  end

  test 'email should be unique' do
    @user.save
    duplicate_user = @user.dup
    assert_not duplicate_user.save, 'Duplicate user saved with same email'
    assert_includes duplicate_user.errors[:email], 'has already been taken', 'Duplicate email error not present'
  end

  test 'email should save with valid email format' do
    valid_emails = ['valid@example.com', 'user.name@example.com', 'user+name@example.com']
    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email.inspect} should be valid"
      assert @user.save, "#{valid_email.inspect} should be saved"
    end
  end

  test 'email should not save without valid email format' do
    invalid_emails = ["invalid@email", "invalid.com", "@email.com"]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email.inspect} should be invalid"
      assert_not @user.save, "#{invalid_email.inspect} should not be saved"
      assert_includes @user.errors[:email], 'is invalid', "#{invalid_email.inspect} should return 'is invalid' error"
    end
  end

  test 'password should be present' do
    @user.password = nil
    assert_not @user.save, 'User saved without a password'
    assert_includes @user.errors[:password], "can't be blank", 'Password blank error not present'
  end

  test 'password should not be blank' do
    @user.password = ' ' * 6
    assert_not @user.save, 'User saved with a blank password'
    assert_includes @user.errors[:password], "can't be blank", 'Blank password error not present'
  end

  test 'password should save if it meets minimum length of 6' do
    @user.password = @user.password_confirmation = 'a' * 6
    assert @user.valid?, 'Password of 6 characters should be valid'
    assert @user.save, 'User not saved with valid password length'
  end

  test 'password should not save if less than minimum length of 6' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.save, 'User saved with a password less than 6 characters'
    assert_includes @user.errors[:password], 'is too short (minimum is 6 characters)', 'Password length error not present'
  end

  test 'password_confirmation should be present' do
    @user.password_confirmation = nil
    assert_not @user.save, 'User saved without a password confirmation'
    assert_includes @user.errors[:password_confirmation], "can't be blank", 'Password confirmation blank error not present'
  end

  test 'password_confirmation should not be blank' do
    @user.password_confirmation = ' ' * 6
    assert_not @user.save, 'User saved with a blank password confirmation'
    assert_includes @user.errors[:password_confirmation], "can't be blank", 'Blank password confirmation error not present'
  end

  test '20 articles are created for user when created' do
    test_user = User.new(email: "testuser@example.com", password: "password123", password_confirmation: "password123")
    assert_difference('Article.count', 20) do
      assert test_user.save
    end
    assert_equal 20, test_user.articles.count, '20 articles were not created for the user'
  end

  test 'user has one user token association' do
    assert_respond_to @user, :user_token, 'User does not have a `has_one` association with user_token'
  end

  test 'deleting user should delete associated user token' do
    @user.save
    @user.create_user_token
    assert_difference("UserToken.count", -1) do
      @user.destroy
    end
  end

  test 'user has one session association' do
    assert_respond_to @user, :session, 'User does not have a `has_one` association with session'
  end

  test 'deleting user should delete associated session' do
    @user.save
    @user.create_session
    assert_difference("Session.count", -1) do
      @user.destroy
    end
  end

  test 'user has many articles association' do
    assert_respond_to @user, :articles, 'User does not have a `has_many` association with articles'
  end

  test 'deleting user should delete associated articles' do
    assert_difference("Article.count", -@user.articles.count) do
      @user.destroy
    end
  end
end
