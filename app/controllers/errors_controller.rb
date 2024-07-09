class ErrorsController < ApplicationController
  skip_before_action :authenticate_request

  def routing
    render json: {
      errors: [
        {
          pointer: 'request_path',
          code: 'routing_error',
          detail: "Route not found: #{request.path}",
          status: 404
        }
      ]
    }, status: :not_found
  end
end