ActiveAdmin.register Marketing::DealSource do

  menu parent: 'Marketing'

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :url_code
      f.input :name
      f.input :image, label: 'Logo Image', as: :file, hint: 'Slider image ideal size: 120x34.'
    end
    f.buttons
  end

end
