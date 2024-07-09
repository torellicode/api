module Api
  module V1
    class ArticlesController < ApplicationController
      include Pagination

      before_action :authenticate_request
      before_action :set_article, only: %i[show update destroy]
      before_action :authorize_article, only: %i[show update destroy]

      def create
        article = current_user.articles.new(article_params)
        if article.save
          render json: { message: 'Article created successfully' }.merge(ArticleSerializer.new(article).serializable_hash), status: :created
        else
          render json: { errors: ErrorFormatter.format_errors(article) }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        render_bad_request_response(e)
      rescue ArgumentError => e
        render_invalid_arguments_response(e)
      end

      def show
        render json: ArticleSerializer.new(@article).serializable_hash, status: :ok
      end

      def index
        paginated_articles = paginate(current_user.articles, page: params[:page], items: params[:per_page] || 10)
        render json: {
          pagination: paginated_articles[:pagination],
          articles: ArticleSerializer.new(paginated_articles[:records]).serializable_hash
        }, status: :ok
      end

      def update
        if @article.update(article_params)
          render json: { message: 'Article updated successfully' }.merge(ArticleSerializer.new(@article).serializable_hash), status: :ok
        else
          render json: { errors: ErrorFormatter.format_errors(@article) }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        render_bad_request_response(e)
      rescue ArgumentError => e
        render_invalid_arguments_response(e)
      end

      def destroy
        if @article.destroy
          render json: { message: 'Article deleted successfully' }, status: :ok
        else
          render json: { errors: ErrorFormatter.format_errors(@article) }, status: :unprocessable_entity
        end
      end

      private

      def set_article
        @article = Article.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render_not_found_response(e)
      end

      def authorize_article
        render_unauthorized_error(UnauthorizedError.new("You are not authorized to access this resource")) unless @article.user_id == current_user.id
      end

      def article_params
        params.require(:article).permit(:title, :content)
      end

      def render_invalid_arguments_response(exception)
        render json: { errors: [ErrorFormatter.invalid_arguments_error(exception)] }, status: :bad_request
      end
    end
  end
end
