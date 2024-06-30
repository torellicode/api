module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from StandardError, with: :internal_server_error
    rescue_from CustomError, with: :custom_error
  end

  private

  def record_not_found(error)
    render json: { errors: [{ pointer: 'record', code: 'not_found', detail: error.message }] }, status: :not_found
  end

  def bad_request(error)
    render json: { errors: [{ pointer: 'parameter', code: 'missing', detail: error.message }] }, status: :bad_request
  end

  def internal_server_error(error)
    render json: { errors: [{ pointer: 'server', code: 'internal_error', detail: error.message }] }, status: :internal_server_error
  end

  def custom_error(error)
    render json: { errors: [{ pointer: error.pointer, code: error.code, detail: error.message }] }, status: error.status
  end
end