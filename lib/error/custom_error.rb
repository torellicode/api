class CustomError < StandardError
  attr_reader :pointer, :code, :status

  def initialize(pointer: 'application', code: 'custom_error', status: :unprocessable_entity, message: nil)
    @pointer = pointer
    @code = code
    @status = status
    super(message)
  end
end
