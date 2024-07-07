module Api
  module V1
    class ArticlesController < ApplicationController
      include Pagination
      include ErrorFormatter

      before_action :set_article, only: %i[show update destroy]

      def create
        article = current_user.articles.new(article_params)
        if article.save
          render json: { message: 'Article created successfully' }.merge(ArticleSerializer.new(article).serializable_hash), status: :created
        else
          render json: format_errors(article.errors.full_messages.join(', ')), status: :unprocessable_entity
        end
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
          render json: format_errors(@article.errors.full_messages.join(', ')), status: :unprocessable_entity
        end
      end

      def destroy
        if @article.destroy
          render json: { message: 'Article deleted successfully' }, status: :ok
        else
          render json: format_errors(@article.errors.full_messages.join(', ')), status: :unprocessable_entity
        end
      end

      private

      def set_article
        @article = current_user.articles.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render json: format_errors(e), status: :not_found
      end

      def article_params
        params.require(:article).permit(:title, :content)
      end
    end
  end
end
