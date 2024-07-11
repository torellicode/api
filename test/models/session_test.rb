require "test_helper"

class SessionTest < ActiveSupport::TestCase
  # == Setup ==

  setup do
    @user = User.create(email: "userone@example.com", password: "password123", password_confirmation: "password123")
    @session = Session.new(user: @user)
  end

  # == Tests ==

  test 'valid user and session created in setup' do
    assert @user.valid?, 'User should be valid'
    assert @session.valid?, 'Session should be valid'
  end

  test 'should generate session id on create' do
    assert_nil @session.session_id
    @session.save
    assert_not_nil @session.session_id
  end

  test 'should be valid with a session_id' do
    @session.save
    assert @session.valid?
  end

  test 'should be invalid without a session_id' do
    @session.save
    @session.session_id = nil
    assert_not @session.valid?
    assert_includes @session.errors[:session_id], "can't be blank"
  end

  test 'session id should be unique' do
    @session.save
    duplicated_session = @session.dup
    assert_not duplicated_session.valid?
    assert_includes duplicated_session.errors[:session_id], "has already been taken"
  end

  test "should generate session_id before validation on create" do
    new_session = Session.new(user: @user)
    assert_nil new_session.session_id
    new_session.valid?
    assert_not_nil new_session.session_id
  end

  test "should belong to a user" do
    association = Session.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
  end

  test 'should be valid with a user' do
    assert @session.valid?
    assert_equal @user, @session.user
  end

  test 'should be invalid without a user' do
    @session.user = nil
    assert_not @session.valid?
    assert_includes @session.errors[:user], "must exist"
  end

  test 'should destroy associated session when user is destroyed' do
    @session.save
    assert_difference('Session.count', -1) do
      @user.destroy
    end
  end
end
