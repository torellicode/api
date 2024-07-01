Rails.logger.info "Requiring custom errors"
require Rails.root.join('lib/errors/custom_error')
require Rails.root.join('lib/errors/unauthorized_error')
require Rails.root.join('lib/errors/error_handler')
Rails.logger.info "Custom errors required"
