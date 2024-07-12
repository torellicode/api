require 'test_helper'

class Api::V1::ArticlesControllerTest < ActionDispatch::IntegrationTest
  # == Setup ==

  setup do
    @article = articles(:one)
    @second_article = articles(:two)
    @user = users(:one)
    @user_two = users(:two)
    login_as(@user)
  end

  # == Helper Methods ==
 
  def article_params(type)
    case type
    when :valid
      { title: 'Article title', content: 'Article content', user: @user }
    when :invalid
      { title: nil, content: nil, user: @user }
    when :invalid_title
      { title: '', content: 'Valid content', user: @user }
    when :title_too_long
      { title: ('a' * 65), content: 'Article content', user: @user }
    when :invalid_content
      { title: 'Valid title', content: '', user: @user }
    when :content_too_long
      { title: 'Valid title', content: ('a' * 257), user: @user }
    when :updated
      { title: 'New title', content: 'New content' }
    end
  end

  def paginated_user_login
    @paginated_user = User.create(email: 'paginated@example.com', password: 'password123', password_confirmation: 'password123')
    login_as(@paginated_user)
  end

  # == Tests ==

  test 'create article with valid params' do
    assert_difference("Article.count", 1) do
      post api_v1_articles_url, headers: authenticated_header, params: { article: article_params(:valid) }
    end
    assert_response :created
    assert_equal "Article created successfully", json_body['message']
  end

  test 'should not create article if title is missing' do
    assert_no_difference("Article.count") do
      post api_v1_articles_url, headers: authenticated_header, params: { article: article_params(:invalid_title) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Title can't be blank"
  end

  test 'should not create article if title is too long' do
    assert_no_difference("Article.count") do
      post api_v1_articles_url, headers: authenticated_header, params: { article: article_params(:title_too_long) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Title is too long (maximum is 64 characters)'
  end

  test 'should not create article if content is missing' do
    assert_no_difference("Article.count") do
      post api_v1_articles_url, headers: authenticated_header, params: { article: article_params(:invalid_content) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Content can't be blank"
  end

  test 'should not create article if content is too long' do
    assert_no_difference("Article.count") do
      post api_v1_articles_url, headers: authenticated_header, params: { article: article_params(:content_too_long) }
    end
    assert_response :unprocessable_entity
    assert_includes error_details, 'Content is too long (maximum is 256 characters)'
  end

  test 'create article with valid token' do
    post api_v1_articles_url, headers: authenticated_header, params: { article: article_params(:valid) }
    assert_response :success
    assert_equal 'Article created successfully', json_body['message']
  end

  test 'should not create article with invalid token' do
    post api_v1_articles_url, headers: invalid_header, params: { article: article_params(:valid) }
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not create article with missing token' do
    post api_v1_articles_url, params: { article: article_params(:valid) }
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'show article with valid token' do
    get api_v1_articles_url(@article), headers: authenticated_header
    assert_response :success
  end

  test 'should not show article with invalid token' do
    get api_v1_articles_url(@article), headers: invalid_header
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not show article with missing token' do
    get api_v1_articles_url(@article)
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'show article that belongs to user' do
    get api_v1_articles_url(@article), headers: authenticated_header
    assert_response :success
  end

  test 'should not show article that does not belong to user' do
    get api_v1_article_url(@second_article), headers: authenticated_header
    assert_response :forbidden
    assert_includes error_details, 'You are not authorized to access this resource'
  end

  test 'show article response contains correct data' do
    get api_v1_article_url(@article), headers: authenticated_header
    assert_response :success
    expected_response = {
      "data" => {
        "id" => @article.id.to_s,
        "type" => "article",
        "attributes" => {
          "title" => @article.title,
          "content" => @article.content,
          "created_at" => @article.created_at.iso8601(3),
          "updated_at" => @article.updated_at.iso8601(3)
        },
        "relationships" => {
          "user" => {
            "data" => {
              "id" => @user.id.to_s,
              "type" => "user"
            }
          }
        }
      }
    }
    assert_equal expected_response, json_body
  end

  test 'should return not found error for invalid article id' do
    get api_v1_article_url(9999), headers: authenticated_header
    assert_response :not_found
    assert_includes error_details, "Couldn't find Article with 'id'=9999"
  end

  test 'get index with valid token' do
    get api_v1_articles_url, headers: authenticated_header
    assert_response :success
  end

  test 'should not get index with invalid token' do
    get api_v1_articles_url, headers: invalid_header
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not get index with missing token' do
    get api_v1_articles_url
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'should get first page of paginated articles' do
    paginated_user_login
    get api_v1_articles_url, headers: authenticated_header, params: { page: 1, per_page: 10 }

    assert_response :success
    assert_equal 10, json_body['articles']['data'].length
    assert_equal "Article 1", json_body['articles']['data'].first['attributes']['title']
  end

  test 'should get second page of paginated articles' do
    paginated_user_login
    get api_v1_articles_url, headers: authenticated_header, params: { page: 2, per_page: 10 }

    assert_response :success
    assert_equal 10, json_body['articles']['data'].length
    assert_equal "Article 11", json_body['articles']['data'].first['attributes']['title']
  end

  test 'should handle invalid negative page number of paginated articles' do
    paginated_user_login
    get api_v1_articles_url, headers: authenticated_header, params: { page: -1, per_page: 10 }

    assert_response :bad_request
    assert_includes error_details, "expected :page >= 1; got \"-1\""
  end

  test 'should handle invalid page number beyond outer boundry of paginated articles' do
    paginated_user_login
    get api_v1_articles_url, headers: authenticated_header, params: { page: 999, per_page: 10 }

    assert_response :bad_request
    assert_includes error_details, "expected :page in 1..2; got 999"
  end

  test 'pagination meta data should be in correct format' do
    paginated_user_login
    get api_v1_articles_url, headers: authenticated_header, params: { page: 1, per_page: 10 }
    assert_response :success
    expected_meta_data_format = {
        "count" => 20,
        "pages" => 2,
        "current_page" => 1,
        "items" => 10
    }
    assert_equal expected_meta_data_format, json_body['pagination']
  end

  test 'update title and content with valid token' do
    assert_no_difference("Article.count") do
      assert_changes -> { [@article.reload.title, @article.reload.content] } do
        put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'Article updated successfully', json_body['message']
  end

  test 'should not update with invalid token' do
    assert_no_difference("Article.count") do
      put api_v1_article_url(@article), headers: invalid_header, params: { article: article_params(:updated) }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not update with missing token' do
    assert_no_difference("Article.count") do
      put api_v1_article_url(@article), params: { article: article_params(:updated) }
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end

  test 'update title with valid params' do
    assert_no_difference("Article.count") do
      assert_changes -> { @article.reload.title }, from: @article.title, to: article_params(:updated)[:title] do
        put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'Article updated successfully', json_body['message']
  end

  test 'should not update title with invalid params' do
    assert_no_difference("Article.count") do
      assert_no_changes -> { @article.reload.title } do
        put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:invalid_title) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Title can't be blank"
  end

  test 'update content with valid params' do
    assert_no_difference("Article.count") do
      assert_changes -> { @article.reload.content }, from: @article.content, to: article_params(:updated)[:content] do
        put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:updated) }
      end
    end
    assert_response :success
    assert_equal 'Article updated successfully', json_body['message']
  end

  test 'should not update content with invalid params' do
    assert_no_difference("Article.count") do
      assert_no_changes -> { @article.reload.content } do
        put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:invalid_content) }
      end
    end
    assert_response :unprocessable_entity
    assert_includes error_details, "Content can't be blank"
  end

  test 'should not update article that does not belong to user' do
    login_as(@user_two)
    assert_no_difference("Article.count") do
      assert_no_changes -> { @article .reload.content } do
        put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:valid) }
      end
    end
    assert_response :forbidden
    assert_includes error_details, 'You are not authorized to access this resource'
  end

  test 'update response should be in correct format' do
    put api_v1_article_url(@article), headers: authenticated_header, params: { article: article_params(:updated) }
    assert_response :success
    @article.reload
    expected_response = {
      "message" => "Article updated successfully",
      "data" => {
        "id" => @article.id.to_s,
        "type" => "article",
        "attributes" => {
          "title" => @article.title,
          "content" => @article.content,
          "created_at" => @article.created_at.iso8601(3),
          "updated_at" => @article.updated_at.iso8601(3)
        },
        "relationships" => {
          "user" => {
            "data" => {
                "id" => @article.user.id.to_s,
                "type" => "user"
            }
          }
        }
      }
    }
    assert_equal expected_response, json_body
  end

  test 'delete article with valid token' do
    assert_difference("Article.count", -1) do
      delete api_v1_article_url(@article), headers: authenticated_header
    end
    assert_response :success
    assert_equal "Article deleted successfully", json_body['message']
  end

  test 'should not delete article with invalid token' do
    assert_no_difference("Article.count") do
      delete api_v1_article_url(@article), headers: invalid_header
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is invalid'
  end

  test 'should not delete article with missing token' do
    assert_no_difference("Article.count") do
      delete api_v1_article_url(@article)
    end
    assert_response :unauthorized
    assert_includes error_details, 'Authorization token is missing'
  end
end