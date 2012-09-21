class Category < ActiveRecord::Base

  has_and_belongs_to_many :plans
  has_many :cross_sells
  has_many :related_categories, through: :cross_sells
  has_many :subscriptions, through: :plans
  has_many :user_preferences, dependent: :destroy
  belongs_to :category_group

  mount_uploader :image, ImageUploader do
    process :resize_to_fill => [886, 314]
  end
  mount_uploader :header_image, ImageUploader do
    process :resize_to_fill => [900, 160]
  end
  mount_uploader :thumbnail, ImageUploader do
    process :resize_to_fill => [241, 176]
  end
  mount_uploader :icon, ImageUploader do
    process :resize_to_fill => [30, 30]
  end

  validates :image, :thumbnail, :icon, :presence => true

  validates_presence_of :name

  default_scope order('categories.name ASC')
  scope :featured, where(is_featured: true)

  def to_s
    self.name
  end

  class << self
    def available_in_city(city)
      ids = Plan.available_in_city(city).select(:id).map {|plan| plan.categories.map(&:id) }.flatten.uniq
      self.where(id: ids)
    end

    def available_in_zipcode(zipcode)
      ids = Plan.available_in_zipcode(zipcode).select(:id).map {|plan| plan.categories.map(&:id) }.flatten.uniq
      self.where(id: ids)
    end

    def with_plans_status(*status)
      self.includes(:plans).where(plans: { status: status })
    end

    def with_at_least_one_plan
      self.where('categories.id IN (
        SELECT categories.id FROM "categories"
        INNER JOIN "categories_plans"
          ON "categories_plans"."category_id" = "categories"."id"
        INNER JOIN "plans"
          ON "plans"."id" = "categories_plans"."plan_id"
        GROUP BY categories.id, categories.name
          HAVING COUNT(plans.id) >= 1
      )')
    end
  end

  def subscriptions_count
    query = <<-eos
      SELECT categories_plans.category_id, (SUM(plans.initial_count) + COUNT(*)) AS count
      FROM subscriptions
      INNER JOIN plan_recurrences
        ON subscriptions.plan_recurrence_id = plan_recurrences.id
      INNER JOIN plans
        ON plan_recurrences.plan_id = plans.id
      INNER JOIN categories_plans
        ON plans.id = categories_plans.plan_id
      GROUP BY categories_plans.category_id
      UNION
        SELECT categories_plans.category_id, SUM(plans.initial_count) AS count
        FROM plans
        INNER JOIN categories_plans
          ON plans.id = categories_plans.plan_id
        GROUP BY categories_plans.category_id
    eos
    @@subscriptions_count ||= ActiveRecord::Base.connection.execute(query)
    make_count(@@subscriptions_count)
  end

  def plans_count
    query = <<-eos
      SELECT categories_plans.category_id, COUNT(*) AS count
      FROM plans
      INNER JOIN categories_plans
        ON plans.id = categories_plans.plan_id
      GROUP BY categories_plans.category_id
    eos
    @@plans_count ||= ActiveRecord::Base.connection.execute(query)
    make_count(@@plans_count)
  end

private
  def make_count(items_count)
    name_with_count = items_count.select {|result| result["category_id"].to_i == self.id }.max {|a, b| a["count"] <=> b["count"] }
    (name_with_count)? name_with_count["count"] : 0
  end
end
