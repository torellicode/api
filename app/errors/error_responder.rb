class ErrorResponder
  def call(env)
    request = ActionDispatch::Request.new(env)
    status = request.path_info[1..].to_i
    exception = env['action_dispatch.exception']
    message = error_message(exception, status)
    attribute = exception.try(:param) || :base
    code = http_status_to_code(status)
    body = { errors: [ErrorDetails.single_error(status: status, attribute: attribute, code: code, message: message)] }
    render_error(status, request.formats.first, body)
  end

  private

  def error_message(exception, status)
    status == 500 ? I18n.t('errors.internal_error.message') : exception.try(:reason)
  end

  def http_status_to_code(status)
    Rack::Utils::HTTP_STATUS_CODES.fetch(status, 'internal_server_error').downcase
  end

  def render_error(status, format, body)
    [status, { 'Content-Type' => "#{format}; charset=#{ActionDispatch::Response.default_charset}" }, [body.to_json]]
  end
end