class HomeController < ApplicationController
  skip_before_action :authenticate_request
  def index
    json_response = {
      github_repositpory: "https://github.com/torellicode/api",
      base_url: "https://torelli-api-e68f6795f068.herokuapp.com",
      endpoints: {
        users: [
          { method: "POST", endpoint: "/api/v1/users" },
          { method: "GET", endpoint: "/api/v1/data" },
          { method: "PUT", endpoint: "/api/v1/users/:user_id" },
          { method: "DELETE", endpoint: "/api/v1/users/:user_id" }
        ],
        sessions: [
          { method: "POST", endpoint: "/api/v1/login" },
          { method: "DELETE", endpoint: "/api/v1/logout" }
        ],
        articles: [
          { method: "POST", endpoint: "/api/v1/articles" },
          { method: "GET", endpoint: "/api/v1/articles" },
          { method: "GET", endpoint: "/api/v1/articles/:article_id" },
          { method: "PUT", endpoint: "/api/v1/articles/:article_id" },
          { method: "DELETE", endpoint: "/api/v1/articles/:article_id" }
        ]
      }
    }

    render json: json_response
  end

  private

  def render(options = nil, extra_options = {}, &block)
    if options.is_a?(Hash) && options[:json]
      options[:json] = JSON.pretty_generate(options[:json])
    end
    super(options, extra_options, &block)
  end
end