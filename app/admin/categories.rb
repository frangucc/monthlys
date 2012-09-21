ActiveAdmin.register Category do

  menu parent: 'Navigation'

  filter :name
  filter :category_group

  index do
    column :id
    column :name
    column :category_group
    column :is_featured
    default_actions
  end

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Category') do |category, attributes|
    attributes.delete(:category_group_id)
    attributes.merge({
      related_categories: category.related_categories.map {|c| { id: c.id, desc: c.name } },
      category_group: category.category_group ? { id: category.category_group_id, desc: category.category_group.name } : nil
    })
  end)

  show do
    dl do
      dt "Name"
      dd category.name
      dt "Is featured?"
      dd category.is_featured?
      dt "Number of plans"
      dd category.plans.count
      dt "Related Categories"
      dd category.related_categories.collect{|c| c.name}.join(', ')
      if category.image?
        dt "Slider Image"
        dd image_tag(category.image.url, :alt => category.name)
      end
      if category.header_image?
        dt "Header Image"
        dd image_tag(category.header_image.url, :alt => category.name)
      end
      if category.thumbnail?
        dt 'Thumbnail'
        dd image_tag(category.thumbnail.url, :alt => category.name)
      end
      if category.icon?
        dt 'Icon'
        dd image_tag(category.icon.url, :alt => category.name)
      end
      unless category.category_group.nil?
        dt "Category Group"
        dd link_to(category.category_group.name, admin_category_group_path(category.category_group))
      end
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :name
      f.input :is_featured
      f.input :related_categories
      f.input :category_group, include_blank: false
      f.input :image, :label => 'Slider Image', :as => :file, :hint => "Slider image ideal size: 886x314px. This will show up on the main slider."
      f.input :header_image, :as => :file, :hint => "Header image ideal size: 900x160px. This will show up as a heading for the category page."
      f.input :thumbnail, :as => :file, :hint => "Thumbnail ideal size: 241x176px"
      f.input :icon, :as => :file, :hint => "Icon ideal size: 30x30px"
    end
    f.buttons
  end
end
