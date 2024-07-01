class UnauthorizedError < CustomError
  def initialize(message = 'Unauthorized access')
    super(pointer: 'authorization', code: 'unauthorized', status: :unauthorized, message: message)
  end
end
