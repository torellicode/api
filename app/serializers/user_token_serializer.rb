class UserTokenSerializer
  include FastJsonapi::ObjectSerializer
  attributes :token, :expires_at, :created_at
  belongs_to :user
end
