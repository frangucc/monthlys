require mp_path('mp/forms/admin_users')

module MP
  module Routes
    UserResource = MP::Routes::Generic::resource_factory(
      resource_name: :admin_user,
      base_url: '/admin_users',
      model_class: User,
      template_path: 'admin_users',
      new_form_class: MP::Forms::NewAdminUser,
      edit_form_class: MP::Forms::EditAdminUser
    )

    class AdminUsers < UserResource
      register Generic::ResourceListRoutes
      register Generic::ResourceNewRoutes
      register Generic::ResourceEditRoutes

      def dataset
        appcontext.current_merchant.users.order(:id)
      end

      get url(:admin_user_change_password, '/admin_users/:id/change_password/') do
        authorize!

        record = find_record_or_404
        form = MP::Forms::UserChangePassword.new(nil, record: record)
        render(template_path(:change_password),
               { form: form, record: record })
      end

      post url(:admin_user_change_password) do
        authorize!

        record = find_record_or_404
        form = MP::Forms::UserChangePassword.new(params, record: record)
        if form.valid?
          form.save(record)
          redirect(url_for(:admin_user_edit, id: record.id))
        end
        render(template_path(:change_password),
               { form: form, record: record })
      end
    end
  end

  Main.use Routes::AdminUsers
end
