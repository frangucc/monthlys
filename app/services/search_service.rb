module SearchService
  module_function

  def search(query, options)
    options = {
      field_weights: { name: 10 }
    }.update(options)

    Plan.search(query, options)
  end

  def json_search(query, options)
    results = search(query, options).map do |p|
      { type: 'plan',
        title: p.name,
        price_description: p.cheapest_plan_recurrence_explanation,
        merchant: p.merchant.business_name,
        image_url: p.thumbnail.url,
        url: Rails.application.routes.url_helpers.plan_path(p) }
    end

    { searchText: query, results: results }
  end

end
