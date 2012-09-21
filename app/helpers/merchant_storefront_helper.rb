module MerchantStorefrontHelper
  DEFAULT_BASE_COLOR = '000000'

  def base_color
    "##{@merchant.custom_site_base_color || DEFAULT_BASE_COLOR}"
  end

  def customize?
    base_color = @merchant.custom_site_base_color
    !base_color.nil? && !base_color.empty?
  end

  def big_icon(name)
    "<span class=\"big-icon #{name}\"><span></span></span>".html_safe
  end

  def storefront_controller?
    params[:controller].start_with?('merchant_storefront')
  end

  def sass_eval(value)
    Sass::Script::Parser.parse(value, 0, 0).perform(Sass::Environment.new).to_s
  end

  def include_linear_gradient(color1, color2)
    <<EOF
    background-color: #{color1};

    background-image: none;
    background-image: -webkit-linear-gradient(top, #{color1} 0%, #{color2} 100%);
    background-image: -moz-linear-gradient(top, #{color1} 0%, #{color2} 100%);
    background-image: -ms-linear-gradient(top, #{color1} 0%, #{color1} 100%);
    background-image: -o-linear-gradient(top, #{color1} 0%, #{color2} 100%);
    background-image: linear-gradient(top, #{color1} 0%, #{color2} 100%);
EOF
  end
end
