module ErrorDetails
  def self.single_error(status: 422, attribute: :base, code: :invalid, message: I18n.t('errors.messages.invalid'))
    { pointer: attribute, code: code, detail: message, status: status }
  end
end