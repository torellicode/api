Rails.application.config.action_dispatch.rescue_responses.merge!(
  'UnauthorizedError' => :forbidden
)