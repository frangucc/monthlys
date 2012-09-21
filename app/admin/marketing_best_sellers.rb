ActiveAdmin.register Marketing::BestSeller do

  menu parent: 'Marketing'

  index do
    column :id
    column :plan
    column :coupon
    column :newsletters do |bs|
      bs.newsletters.map(&:subject).join(', ')
    end
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :plan, as: :select, collection: Plan.has_status(:active).all.map {|p| [p.name, p.id] }
      f.input :coupon, as: :select, collection: Coupon.active.available_to_selected_plans.all.map {|c| ["#{c.coupon_code} - #{c.name}", c.id] }
      f.input :order
      f.input :newsletters
    end
    f.buttons
  end

end
