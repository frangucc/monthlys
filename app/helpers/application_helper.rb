module ApplicationHelper
  def markdown(text)
    Redcarpet.new(text, :hard_wrap, :autolink).to_html.html_safe if text
  end

  def display_flash
    flash.map do |name, msg|
      content = if msg.is_a?(Array)
        msg.map {|v| "<p>#{v}</p>".html_safe }.join
      elsif msg.is_a?(Hash)
        msg.map {|k, v| "<p>#{k}, #{v}</p>".html_safe }.join
      else
        msg.to_s
      end.html_safe
      content_tag :div, content, :class => "message flash-#{name}"
    end.join.html_safe
  end

  def body_class
    classes = []
    classes << "#{params[:controller].parameterize}-controller"
    classes << "#{params[:controller].parameterize}-#{params[:action].parameterize}"
    classes.join(' ')
  end

  def latitude
    (session[:location] && session[:location][:latitude])? session[:location][:lattude] : ''
  end

  def longitude
    (session[:location] && session[:location][:longitude])? session[:location][:longitude] : ''
  end

  def default_image
    "/assets/default/default_backgrounds/background_0.jpg"
  end

  def current_city_image
    current_city && !current_city.image.blank? && current_city.image.url
  end

  def current_image
    if current_city_image
      image_tag current_city_image, class: 'bg city_image'
    else
      image_tag default_image, class: 'bg'
    end
  end

  def switch(is_on, large = false)
    html  = "<div class='buttontrack#{' on' if is_on}#{' large' if large}'>"
    html += " <span class='label on#{' large' if large}'>ON</span>"
    html += " <span class='label off#{' large' if large}'>OFF</span>"
    html += " <div class='button#{' large' if large}'>"
    html += " </div>"
    html += "</div>"
    html.html_safe
  end

  # Get asset absolute url
  def asset_url(asset)
    "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end

  def admin_user_filter_link(type, sessions_type, position = "", alt = "")
    content = "Show #{type.to_s.humanize}"
    content = (sessions_type == type)? "<strong>#{content}</strong>".html_safe : content
    link_to(content, update_location_settings_path(:type => type), :class => position, :alt => alt)
  end

  def twitter_share_button
    "<a href='http://twitter.com/home?status=Monthlys - http://monthlys.com' target='_blank' class='twitter'>Share on Twitter</a>".html_safe
  end

  def facebook_share_button
    "<a href='http://facebook.com/sharer.php?u=http://monthlys.com' target='_blank' class='facebook'>Like on Facebook</a>".html_safe
  end

  def googleplus_share_button
    "<a href='https://plusone.google.com/_/+1/confirm?hl=en&url=http://monthlys.com' target='_blank' class='google'>Share in Google Plus</a>".html_safe
  end

  # YouTube:
  # URL is the not-embeddable URL for a YouTube video.
  def get_youtube_video_id(url)
    $1 if /v=(.{11})/ =~ url
  end

  def get_youtube_video_thumbnail(url)
    "//img.youtube.com/vi/#{get_youtube_video_id(url)}/0.jpg"
  end

  def get_youtube_video_embed(url, autoplay = false)
    "//www.youtube.com/embed/#{get_youtube_video_id(url)}?showinfo=0&rel=0&wmode=opaque#{autoplay ? '&autoplay=1' : ''}"
  end

  def merchant_ships_to(merchant)
    if merchant.nationwide?
      'nationwide'
    elsif merchant.state_list?
      merchant.states_list
    elsif merchant.city_list?
      merchant.cities_list
    elsif merchant.zipcode_list?
      merchant.zipcodes_list
    end
  end

  def starting_at_price(plan)
    unless plan.cheapest_plan_recurrence.nil?
      "#{plan.cheapest_plan_recurrence_explanation}"
    else
      ""
    end
  end

  def show_get_started?
    !cookies[:get_started]
  end

  def show_header_promo?
    !cookies[:header_promo] && params[:controller] != 'registrations'
  end

  def analytics_track_event(category, action, label)
    "_trackEvent('#{category}', '#{action}', '#{label}')"
  end

  def billing_desc_abbr(billing_desc)
    [ [ 'months?', 'mo' ],
      [ 'years?', 'yr' ],
      [ 'every ?', '/']
    ].each { |w, abbr| billing_desc.gsub!(/#{w}/, abbr) }
    billing_desc
  end

  def requirejs(*modnames)
    modnames = "'#{modnames.join("', '")}'"
    ["require(['require', #{modnames}], function (require) {",
     "  require(#{modnames});",
     "});"].join.html_safe
  end

  def asset(path)
    default_path = "/assets/#{path}"
    return default_path unless Monthly::Config::ASSETS_DIGESTS

    altpath = Monthly::Config::ASSETS_DIGESTS_ALTERNATIVES[path]
    altpath ? "/assets/#{altpath}" : default_path
  end
end
