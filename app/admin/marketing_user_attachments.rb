ActiveAdmin.register Marketing::UserAttachment do

  actions :index, :show

  menu parent: 'Marketing', label: 'Stickit contest submissions'

  index do
    column :id
    column :user
    column :name
    column :email
    column :image do |marketing_user_attachment|
      image_tag marketing_user_attachment.image.url, width: 150
    end
    column :attachment_type
    column :created_at
  end

  show do
    attributes_table do
      row :id
      row :user
      row :email
      row :name
      row :image do |marketing_user_attachment|
        image_tag marketing_user_attachment.image.url
      end
      row :attachment_type
      row :created_at
    end
    active_admin_comments
  end
end
