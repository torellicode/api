module AuthenticationErrors
  class MissingTokenError < StandardError; end
  class InvalidTokenError < StandardError; end
  class ExpiredTokenError < StandardError; end
end