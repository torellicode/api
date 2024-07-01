class User < ApplicationRecord
  has_secure_password

  has_one :user_token, dependent: :destroy
  has_one :session, dependent: :destroy
  has_many :articles, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: true }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true, length: { minimum: 6 }, allow_nil: true

  after_create :create_initial_articles

  private

  def create_initial_articles
    20.times do |i|
      articles.create(title: "Article #{i + 1}", content: "This is the content of article #{i + 1}.")
    end
  end
end
