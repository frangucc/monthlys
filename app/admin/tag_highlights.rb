ActiveAdmin.register TagHighlight, as: 'Tag highlights' do

  menu parent: 'Navigation'

  index do
    column :id
    column :tag
    column 'Type' do |h|
      h.highlight_type.humanize
    end
    column :highlight do |h|
      highlight_link(h)
    end
    column :title
    column :price do |h|
      get_price_display(h)
    end
    column :ordering
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :tag
      row :highlight do |h|
        highlight_link(h)
      end
      row :image do |h|
        (h.image.blank?) ? '' : image_tag(h.image.url)
      end
      row :ordering
      row :title
      row :price do |h|
        get_price_display(h)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Details' do
      f.input :tag, collection: Tag.where(is_featured: true), include_blank: false
      f.input :highlight_type, as: :select, collection: get_highlight_type_collection, include_blank: false
      f.input :plan, collection: Plan.where(status: :active).order(:name), include_blank: false
      f.input :category, include_blank: false
      f.input :ordering
      f.input :image, required: true
      f.input :on_sale
      f.input :title, hint: 'Overrides plan\'s name'
      f.input :price_amount, hint: 'Overrides plan\'s price'
      f.input :price_recurrence, hint: 'Overrides plan\'s billing recurrence'
    end
    f.buttons
  end
end

# AA Helpers

def highlight_link(h)
  fk = h.send(h.highlight_type.foreign_key)
  model = h.highlight_type.constantize
  obj = model.find(fk)
  show_path = self.send("admin_#{h.highlight_type.underscore}_path", obj)
  "#{h.highlight_type.humanize}: #{link_to(obj.to_s, show_path)}".html_safe
end

def get_highlight_type_collection
  TagHighlight.get_types.map { |t| [t.humanize, t] }
end

def get_price_display(h)
  if h.highlight_type == 'Plan'
    if h.price_amount || !h.price_recurrence.empty?
      "$ #{h.price_amount} #{h.price_recurrence}"
    else
      pr = h.plan.cheapest_plan_recurrence
      "$ #{pr.pretty_amount} #{pr.billing_desc}"
    end
  else
    ''
  end
end