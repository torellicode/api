module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
    rescue_from ActionController::ParameterMissing, with: :render_bad_request_response
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_parse_error_response
    rescue_from ActionController::RoutingError, with: :render_routing_error_response
  end

  private

  def render_unprocessable_entity_response(exception)
    render json: { errors: ErrorFormatter.format_errors(exception.record) }, status: :unprocessable_entity
  end

  def render_bad_request_response(exception)
    render json: { errors: [ErrorFormatter.parameter_missing_error(exception)] }, status: :bad_request
  end

  def render_not_found_response(exception)
    render json: { errors: [ErrorFormatter.record_not_found_error(exception)] }, status: :not_found
  end

  def render_parse_error_response(exception)
    render json: { errors: [ErrorFormatter.parse_error(exception)] }, status: :bad_request
  end

  def render_routing_error_response(exception)
    render json: { errors: [ErrorFormatter.routing_error(exception)] }, status: :not_found
  end
end