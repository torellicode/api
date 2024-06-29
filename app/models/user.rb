class User < ApplicationRecord
  has_secure_password

  has_one :user_token, dependent: :destroy
  has_one :session, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: true }
end
