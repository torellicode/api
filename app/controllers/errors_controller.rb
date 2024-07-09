class ErrorsController < ApplicationController
  skip_before_action :authenticate_request

  def routing
    render json: {
      errors: [
        {
          status: 404,
          code: 'routing_error',
          detail: "Route not found: #{request.path}",
          pointer: 'request_path'
        }
      ]
    }, status: :not_found
  end
end