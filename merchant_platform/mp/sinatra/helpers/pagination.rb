module MP
  module SinatraHelpers
    module Pagination
      def paginate(dataset, limit = 15)
        count = dataset.count
        divmod = count.divmod(limit)
        top_page = divmod[0] + (divmod[1] > 0 ? 1 : 0) - 1  # -1 because it 0-index
        top_page = 0 if top_page < 0

        page = (params[:page] || 0).to_i
        page = page.to_i
        page = 0 if page < 0
        page = top_page if page > top_page

        offset = page * limit

        prev_page = page - 1 if page > 0
        next_page = page + 1 if page < top_page

        if page == top_page
          current_items_top = count
        else
          current_items_top = offset + limit
        end

        { current_page: page,
          current_items_base: offset,
          current_items_top: current_items_top,
          count: count,
          prev_page: prev_page,
          next_page: next_page,
          items: dataset.offset(offset).limit(limit) }
      end
    end
  end
end

