class ExpiredTokenError < StandardError
  def message
    "Token expired"
  end
end