ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'minitest/reporters'


Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

class ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  # Run tests in the order they are defined (sorted order)
  # self.test_order = :sorted

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def login_as(user)
    post api_v1_login_url, params: { email: user.email, password: 'password123' }
    @token = json_body['data']['token']
  end

  def authenticated_header
    { 'Authorization': "Bearer #{@token}" }
  end

  def invalid_header
    { 'Authorization': 'Bearer invalid_token' }
  end

  def json_body
    JSON.parse(response.body)
  end

  def error_details
    json_body['errors'].map { |error| error['detail'] }
  end
end
