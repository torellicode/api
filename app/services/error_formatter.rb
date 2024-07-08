class ErrorFormatter
  class << self
    def format_errors(model, *prefix)
      model.errors.details.map do |attribute, details|
        format_error_details(model, prefix, attribute, details)
      end.flatten
    end

    def parameter_missing_error(exception)
      ErrorDetails.single_error(
        status: 400,
        attribute: exception.param,
        code: 'parameter_missing',
        message: exception.message
      )
    end

    def record_not_found_error(exception)
      ErrorDetails.single_error(
        status: 404,
        attribute: 'id',
        code: 'record_not_found',
        message: exception.message
      )
    end

    def missing_token_error(exception)
      ErrorDetails.single_error(
        status: 400,
        attribute: 'authorization',
        code: 'missing_token',
        message: 'Authorization token is missing'
      )
    end

    def invalid_token_error(exception)
      ErrorDetails.single_error(
        status: 401,
        attribute: 'authorization',
        code: 'invalid_token',
        message: 'Authorization token is invalid'
      )
    end

    def expired_token_error(exception)
      ErrorDetails.single_error(
        status: 401,
        attribute: 'authorization',
        code: 'expired_token',
        message: 'Authorization token has expired'
      )
    end

    def unauthorized_error(exception)
      ErrorDetails.single_error(
        status: 403,
        attribute: 'authorization',
        code: 'unauthorized_access',
        message: exception.reason || 'You are not authorized to access this resource'
      )
    end

    def invalid_login_error
      ErrorDetails.single_error(
        status: 422,
        attribute: 'authentication',
        code: 'invalid_login',
        message: 'Invalid email or password'
      )
    end

    private

    def format_error_details(model, prefix, attribute, details)
      details.map.with_index do |error, index|
        if error[:value].respond_to?(:errors)
          format_errors(error[:value], [*prefix, attribute])
        else
          code = error[:error]
          message = full_error_message(model, attribute, index, code)
          ErrorDetails.single_error(attribute: [*prefix, attribute].compact.join('.'), code: code, message: message)
        end
      end
    end

    def full_error_message(model, attribute, index, code)
      message = model.errors.full_message(attribute, model.errors.messages[attribute][index])
      message += allowed_error_values(model, attribute) if code == :inclusion
      message
    end

    def allowed_error_values(model, attribute)
      validator = model.class.validators_on(attribute).find { |v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
      if validator
        values = validator.options[:in]
        I18n.t('errors.messages.inclusion_addition', values: values.join(', '))
      else
        ''
      end
    end
  end
end
