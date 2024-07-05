module Errors
  class InvalidTokenError < StandardError
    def message
      "Invalid token or format"
    end
  end
end
