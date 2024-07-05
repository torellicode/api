class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :email, :created_at, :updated_at
  attribute :articles_count do |user|
    user.articles.count
  end
end
