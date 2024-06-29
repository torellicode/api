# app/models/user_token.rb
class UserToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token = SecureRandom.hex(20)
    self.expires_at = 1.hour.from_now
  end
end
