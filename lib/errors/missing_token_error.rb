module Errors
  class MissingTokenError < StandardError
    def message
      "Token is missing or invalid"
    end
  end
end
