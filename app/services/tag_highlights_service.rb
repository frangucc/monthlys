module TagHighlightsService
  module_function

  def get_categories_json
    categories = Category.where(is_featured: true).map do |c|
      { id: c.id,
        name: c.name,
        url: Rails.application.routes.url_helpers.category_path(c),
        image: c.thumbnail.url }
    end

    r = { status: :ok, type: :more, categories: categories }
  end

  def get_tag_json(tag_slug)
    tag = Tag.find_by_slug(tag_slug)
    return get_error_json('Invalid tag') unless tag && tag.is_featured

    tag_data = {
      name: tag.keyword,
      slug: tag.slug,
      url: Rails.application.routes.url_helpers.tag_path(tag)
    }

    highlights = TagHighlight
      .includes({ plan: [ :plan_recurrences, :merchant ] }, :category)
      .where(tag_id: tag.id)
      .order(:ordering)

    highlights_hash = highlights.map do |th|
      if (th.highlight_type == 'Plan')
        merchant = th.plan.merchant.business_name
        if true && th.price_amount && !th.price_recurrence.empty?
          price_recurrence = th.price_recurrence
          price_amount = th.price_amount
        else
          pr = th.plan.plan_recurrences.where(is_active: true).min_by{ |pr| pr.amount }
          price_amount = pr.amount
          price_recurrence = pr.billing_desc
        end
        price_amount = sprintf('%.02f', price_amount).sub(/\.00$/, '')
        is_video_featured = !th.plan.merchant.video_url.blank?
      else
        merchant = price_amount = price_recurrence = nil
        is_video_featured = false
      end

      url = th.get_url
      url += '?autoplay=1' if is_video_featured

      { id: th.id,
        plan_id: (th.highlight_type == 'Plan') ? th.plan.id : nil,
        type: th.highlight_type.underscore,
        image: th.image.url,
        price_amount: price_amount,
        price_recurrence: price_recurrence,
        on_sale: th.on_sale?,
        is_video_featured: is_video_featured,
        url: url,
        merchant: merchant,
        title: th.get_title }
    end

    r = { status: :ok, type: :tag, tag: tag_data, highlights: highlights_hash }
  end

  def get_error_json(msg)
    return { status: 'error', message: msg }
  end

end
