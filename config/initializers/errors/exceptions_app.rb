Rails.application.config.exceptions_app = ->(env) { ErrorResponder.new.call(env) }
