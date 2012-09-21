xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  xml.url do
    xml.loc root_url
    xml.priority 1.0
  end

  [
    :home,
    :coming_soon,
    :about,
    :how_it_works,
    :terms_of_service,
    :affiliate_program,
    :privacy_policy,
    :why_monthlys,
    :what_is_monthlys,
    :jobs,
    :quality,
    :guarantee,
    :contact,
    :affiliate_program
  ].each do |route|
    xml.url do
      xml.loc send("#{route}_url")
      xml.priority 0.8
    end
  end

  @categories.each do |category|
    xml.url do
      xml.loc category_url(category)
      xml.priority 0.9
    end
  end

  @plans.each do |plan|
    xml.url do
      xml.loc plan_url(plan)
      xml.lastmod plan.updated_at.to_date
      xml.priority 0.9
    end
  end
end
