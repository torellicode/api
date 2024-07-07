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
    resource = extract_resource_from_controller.capitalize

    case error
    when Errors::MissingTokenError, Errors::InvalidTokenError, Errors::ExpiredTokenError
      [error.message]
    when ActiveModel::Errors
      error.full_messages.map { |msg| "#{resource}: #{msg}" }
    when ActiveRecord::RecordInvalid
      error.record.errors.full_messages.map { |msg| "#{resource}: #{msg}" }
    when ActiveRecord::RecordNotFound
      ["#{resource} not found"]
    when ActionController::ParameterMissing
      ["Parameter missing: #{error.param}"]
    else
      custom_or_default_message(error, resource)
    end
  rescue => e
    ["An error occurred, but could not extract specific message: #{e.message}"]
  end

  def custom_or_default_message(error, resource)
    ["#{resource}: #{error.message || 'An unknown error occurred'}"]
  end

  def extract_resource_from_controller
    controller_name.singularize
  end
end
