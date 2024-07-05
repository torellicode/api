module Errors
  class MissingTokenError < StandardError
    def message
      "Token is missing"
    end
  end
end
