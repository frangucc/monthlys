class GeocoderService

  attr_accessor :city, :zipcode, :plans_type, :data

  def initialize(user, geocoding_session)
    # TODO: CHECK THAT USER IS ADMIN!
    self.data = geocoding_session
    self.plans_type = data[:plans_type].try(:to_sym)
    self.zipcode = search_zipcode(user, data)
    self.city = search_city(user, data)
  end

  def city_id
    city.try(:id)
  end

  def zipcode_id
    zipcode.try(:id)
  end

  def set_zipcode(zipcode)
    data.delete(:city_id)
    data[:zipcode_id] = zipcode.id
  end

  def set_city(city)
    data.delete(:zipcode_id)
    data[:city_id] = city.id
  end

  def set_plans_type(plans_type)
    data[:plans_type] = plans_type.to_sym unless plans_type.blank?
  end

  def clear
    data.delete([:city_id, :zipcode_id])
  end

  def available_plans_with_category(category, options = {})
    unless @available_plans_with_category
      @available_plans_with_category = filter_plans(category.plans, options)
    end
    @available_plans_with_category
  end

  def available_plans_without_category(filter = {})
    filter_plans(Plan.scoped, filter)
  end

  def available_plans_with_category_group(category_group, options = {})
    unless @available_plans_with_category_group
      @available_plans_with_category_group = filter_plans(category_group.plans, options)
    end
    @available_plans_with_category_group
  end

  def filter_plans(plans_scope, filter = {})
    plans = case plans_type
            when :all then plans_scope.unscoped
            when :all_active then plans_scope.has_status(:active)
            when :all_pending then plans_scope.has_status(:pending)
            when :pending then filter_plans_by_location(plans_scope.has_status(:pending))
            else filter_plans_by_location(plans_scope.has_status(:active))
            end

    plans = plans.where(plan_type: filter[:plan_type]) unless filter[:plan_type].blank?
    if !filter[:min_price].blank? && !filter[:max_price].blank?
      plans = plans.with_price_range(filter[:min_price].to_i, filter[:max_price].to_i)
    end

    plans = case filter[:discover].try(:to_sym)
            when :handpicked then plans.featured
            when :popular then plans.sort_by(&:subscriptions_count).reverse
            when :latest then plans.latest
            when :more then plans.more
            else plans
            end

    plans
  end

  def available_categories(options = {})
    unless @available_categories
      plans = available_plans_without_category(options)
      category_ids = plans.map(&:category_ids).flatten.uniq
      @available_categories = Category.where(id: category_ids)
    end
    @available_categories
  end

  def grouped_available_categories(options = {})
    available_categories(options).reject {|c| c.category_group.nil? }.group_by {|c| c.category_group }.sort_by {|cg, _| cg.name }
  end

  def search_zipcode(user, data)
    if user && user.zipcode && !data[:city_id]
      user.zipcode
    elsif !user && data[:zipcode_id]
      Zipcode.find_by_id(data[:zipcode_id])
    end
  end

  def search_city(user, data)
    # If we have a current user with a zipcode use it
    if data[:city_id].present?
      City.find(data[:city_id])
    elsif self.zipcode
      self.zipcode.city
    elsif data[:latitude] && data[:longitude]
      geo = Geocoder.search([params[:latitude], params[:longitude]]).first
      City.find_by_google_name_and_state_code(geo.city, geo.state_code) if geo
    end
  end

  def filter_plans_by_location(plans_scope)
    if self.zipcode
      plans_scope.available_in_zipcode(self.zipcode)
    elsif self.city
      plans_scope.available_in_city(self.city)
    else
      plans_scope
    end
  end

  def filter_categories_by_location(categories_scope)
    if self.zipcode
      categories_scope.available_in_zipcode(self.zipcode)
    elsif self.city
      categories_scope.available_in_city(self.city)
    else
      categories_scope
    end
  end
end
