require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # == Setup ==

  setup do
    @user = users(:one)
    @second_user = users(:two)
    @article = @user.articles.build(title: 'Article title', content: 'Article content')
  end

  # == Helper Methods ==

  # == Tests ==

  test 'valid article created in setup' do
    assert @article.valid?, 'Article in setup is not valid'
  end

  test 'title should be present' do
    @article.title = nil
    assert_not @article.save
    assert_includes @article.errors[:title], "can't be blank", 'Title presence validation error not found'
  end

  test 'title cannot be blank' do
    @article.title = ' ' * 10
    assert_not @article.save
    assert_includes @article.errors[:title], "can't be blank", 'Title valid with whitespace'
  end

  test 'title should save at exact maximum length' do
    @article.title = "a" * 64
    assert @article.save
  end

  test 'title cannot exceed length of 64 characters' do
    @article.title = "a" * 65
    assert_not @article.save
    assert_includes @article.errors[:title], 'is too long (maximum is 64 characters)', 'Title valid when exceeding maximum length'
  end

  test 'content should be present' do
    @article.content = nil
    assert_not @article.save
    assert_includes @article.errors[:content], "can't be blank", 'Content valid when missing'
  end

  test 'content cannot be blank' do
    @article.content = ' ' * 10
    @article.save
    assert_includes @article.errors[:content], "can't be blank", 'Content valid whith whitespace'
  end

  test 'content should save at exact maximum length' do
    @article.content = 'a' * 256
    @article.save
  end

  test 'content cannot exceed length of 256 characters' do
    @article.content = 'a' * 257
    @article.save
    assert_includes @article.errors[:content], 'is too long (maximum is 256 characters)', 'Content valid when exceeding maximum length'
  end

  test 'should belong to user' do
    association = Article.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro, 'Article should belong to a user'
  end
end
