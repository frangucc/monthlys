module Marketing::NewslettersHelper

  def email_for(browser_url, &block)
    content_for :content, &block
    render partial: 'marketing/newsletters/email_template.html.erb', locals: { browser_url: browser_url }
  end

  def best_seller_link_for(best_seller)
    plan_url(best_seller.plan, coupon: best_seller.coupon.try(:coupon_code))
  end

end
