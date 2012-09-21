ActiveAdmin.register AdminUser do

  menu parent: 'Users'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('AdminUser') do |admin_user, attributes|
    [:encrypted_password, :reset_password_token, :reset_password_sent_at].each do |delete_attribute|
      attributes.delete(delete_attribute)
    end

    attributes
  end)

  index do
    column :id
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
    end
    f.buttons
  end
end
