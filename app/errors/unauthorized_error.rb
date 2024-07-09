class UnauthorizedError < StandardError
  attr_accessor :reason

  def initialize(reason = nil)
    @reason = reason
  end
end