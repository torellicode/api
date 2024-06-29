# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user

  validates :session_id, presence: true, uniqueness: true

  before_validation :generate_session_id, on: :create

  private

  def generate_session_id
    self.session_id = SecureRandom.hex(20)
  end
end
