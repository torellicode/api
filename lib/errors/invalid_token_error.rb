module Errors
  class InvalidTokenError < StandardError
    def message
      "Invalid token"
    end
  end
end
