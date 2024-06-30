class SessionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :session_id, :created_at
  belongs_to :user
end
