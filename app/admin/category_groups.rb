ActiveAdmin.register CategoryGroup do

  menu :parent => "Navigation"
  filter :name

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('CategoryGroup') do |category_group, attributes|
    attributes.merge({
      categories: category_group.categories.map {|c| { id: c.id, desc: c.name } }
    })
  end)

  index do
    column :id
    column :name
    column "Categories", :categories do |cg|
      cg.categories.map(&:name).join(', ')
    end
    default_actions
  end

  show do
    dl do
      dt 'Name'
      dd category_group.name
      if category_group.image?
        dt 'Image'
        dd image_tag(category_group.image.url, alt: category_group.name)
      end
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :name
      f.input :image, :as => :file, :hint => "Header image ideal size: 900x160px. This will show up as a heading for the category group page."
      f.input :categories
    end
    f.buttons
  end
end
