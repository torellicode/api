module ErrorFormatter
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_generic_error
  end

  private

  def handle_generic_error(error)
    render json: format_errors(error), status: extract_status(error)
  end

  def format_errors(error)
    {
      type: extract_type(error),
      errors: extract_messages(error),
      status: extract_status(error)
    }
  rescue => e
    {
      type: 'internal_server_error',
      errors: ["An error occurred, but could not extract specific message: #{e.message}"],
      status: 500
    }
  end

  def extract_type(error)
    error.class.name.demodulize.underscore
  end

  def extract_status(error)
    ActionDispatch::ExceptionWrapper.status_code_for_exception(error.class.name)
  end

  def extract_messages(error)
    case error
    when ActiveModel::Errors
      error.full_messages
    when ActiveRecord::RecordInvalid
      error.record.errors.full_messages
    when ActiveRecord::RecordNotFound
      ["Record not found"]
    when ActionController::ParameterMissing
      ["Parameter missing: #{error.param}"]
    when ActionController::RoutingError
      ["Routing error"]
    when ActionController::UnknownFormat
      ["Unknown format"]
    when ActionController::UnknownHttpMethod
      ["Unknown HTTP method"]
    when ActionController::InvalidAuthenticityToken
      ["Invalid authenticity token"]
    when ActionController::InvalidCrossOriginRequest
      ["Invalid cross-origin request"]
    when ActionController::MissingExactTemplate
      ["Missing exact template"]
    when ActionController::BadRequest
      ["Bad request"]
    else
      custom_or_default_message(error)
    end
  rescue => e
    ["An error occurred, but could not extract specific message: #{e.message}"]
  end

  def custom_or_default_message(error)
    custom_error?(error) ? [error.message] : [error.message || "An unknown error occurred"]
  end

  def custom_error?(error)
    error.is_a?(MissingTokenError) ||
      error.is_a?(InvalidTokenError) ||
      error.is_a?(ExpiredTokenError)
  end
end
