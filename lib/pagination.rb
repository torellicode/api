module Pagination
  extend ActiveSupport::Concern
  include Pagy::Backend

  def paginate(collection, page: 1, items: 10)
    pagy, records = pagy(collection, page: page, items: items)
    {
      records: records,
      pagination: {
        count: pagy.count,
        pages: pagy.pages,
        current_page: pagy.page,
        items: pagy.items
      }
    }
  end
end