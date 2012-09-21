ActiveAdmin.register City do

  menu :parent => "Navigation"

  filter :state
  filter :name
  filter :google_name

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('City') do |city, attributes|
    attributes.delete(:state_id)
    attributes.merge({
      state: city.state ? { id: city.state_id, desc: city.state.code } : nil
    })
  end)

  index do
    column :id
    column :name
    column :state
    column :is_featured
    column "Actions" do |city|
      [
        link_to('View', admin_city_path(city)),
        link_to('Edit', edit_admin_city_path(city))
      ].join(' ').html_safe
    end
  end

  show do
    dl do
      dt "Name"
      dd city.name
      dt "State"
      dd city.state
      dt "Is featured?"
      dd city.is_featured?.to_s
      if city.image?
        dt "Image"
        dd image_tag(city.image.url, alt: city.name)
      end
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :name, hint: 'Changing the city name is NOT RECOMMENDED'
      f.input :state, as: :select, collection: State.all.map {|st| [st.code, st.id] }, hint: 'Changing the state is NOT RECOMMENDED', include_blank: false
      f.input :is_featured
      f.input :image, as: :file, hint: 'Image ideal size: 1440x900px'
    end
    f.buttons
  end
end
