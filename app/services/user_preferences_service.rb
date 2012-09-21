class UserPreferencesService

  attr_accessor :user

  def initialize(target_user)
    self.user = target_user
  end

  def merchant_out_of_area(merchant)
    if zipcode
      categories = merchant.plans.map(&:categories).flatten.uniq
      add_user_preferences(categories)
    end
  end

  def plan_out_of_area(plan)
    add_user_preferences(plan.categories) if zipcode
  end

  def set_zipcode(new_zipcode)
    @zipcode = new_zipcode
    self
  end

private
  def zipcode
    @zipcode || (user && user.zipcode)
  end

  def add_user_preferences(categories)
    categories.each do |category|
      user.user_preferences.create(category: category, zipcode: zipcode) unless categories_taken.include?(category)
    end
  end

  def categories_taken
    @categories_taken ||= user.user_preferences.includes(:category).map(&:category)
  end
end
