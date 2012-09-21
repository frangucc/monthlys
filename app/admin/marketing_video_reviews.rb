ActiveAdmin.register Marketing::VideoReview do

  menu parent: 'Marketing'

  index do
    column :id
    column :title
    column :author
    column :is_featured

    default_actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :title
      f.input :author
      f.input :raw_url, hint: 'This is an "Embed" URL from GetBravo or YouTube.'
      f.input :plan
      f.input :thumbnail, as: :file, hint: 'Header image ideal size: 900x160px.'
      f.input :is_featured
      f.input :is_active
    end
    f.buttons
  end

end
