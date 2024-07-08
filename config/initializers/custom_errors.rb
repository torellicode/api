class UnauthorizedError < StandardError
  attr_accessor :reason

  def initialize(reason = nil)
    @reason = reason
  end
end

Rails.application.config.action_dispatch.rescue_responses.merge!(
  'UnauthorizedError' => :forbidden
)