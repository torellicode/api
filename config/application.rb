require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    config.load_defaults 7.1

    # Autoload lib and custom error paths
    config.paths.add 'lib', eager_load: true
    config.paths.add 'app/errors', eager_load: true

    config.api_only = true
  end
end