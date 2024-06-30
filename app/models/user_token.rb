class UserToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create

  def self.encryptor
    key = ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(Rails.env.to_sym, :encryption_key)).generate_key(Rails.application.credentials.dig(Rails.env.to_sym, :encryption_salt), 32)
    ActiveSupport::MessageEncryptor.new(key)
  end

  def self.decode(encrypted_token)
    decrypted_data = encryptor.decrypt_and_verify(encrypted_token)
    JSON.parse(decrypted_data, symbolize_names: true)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  private

  def generate_token
    payload = { user_id: user.id, raw_token: SecureRandom.hex(20) }
    self.token = self.class.encryptor.encrypt_and_sign(payload.to_json)
    self.expires_at = 1.hour.from_now
  end
end