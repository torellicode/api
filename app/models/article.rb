class Article < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 64 }
  validates :content, presence: true, length: { maximum: 256 }
end
