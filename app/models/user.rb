class User < ApplicationRecord
  has_secure_password

  has_one :user_token, dependent: :destroy
  has_one :session, dependent: :destroy
  has_many :articles, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, uniqueness: { case_sensitive: true }, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true, length: { minimum: 6 }

  after_create :create_initial_articles

  private

  def create_initial_articles
    20.times do |i|
      articles.create(title: "Article #{i + 1}", content: "This is the content of article #{i + 1}.")
    end
  end
end
