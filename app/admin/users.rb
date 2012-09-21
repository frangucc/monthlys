ActiveAdmin.register User do

  actions :index, :show, :toggle

  around_filter &Monthly::AdminActivityLogger.get_around_filter_block_for('User', { extra_actions: %w(toggle mark_as_test mark_as_non_test) })

  filter :email
  filter :full_name
  filter :phone
  filter :company_name
  filter :is_test, as: :select, label: 'Is test'
  filter :zipcode, collection: proc { Zipcode.order(:number).all }

  actions :index, :edit, :show, :create, :update, :new, :toggle

  member_action :toggle do
    @user = User.find(params[:id])
    if @user.toggle(:is_active).save
      redirect_to({:action => :index}, :notice => "User status toggled")
    else
      redirect_to({:action => :index}, :notice => @user.errors.full_messages)
    end
  end

  index do
    column :id
    column :email
    column :zipcode
    column :city
    column :is_active
    column :created_at
    column 'Actions' do |user|
      link_to('View', admin_user_path(user))
    end
  end

  sidebar :preferences, only: :index do
    ul do
      li link_to "View User Preferences", preferences_admin_users_path
    end
  end

  collection_action :preferences, :method => :get do
    @users_with_preferences = []
    User.find_each do |user|
      @users_with_preferences << user unless user.user_preferences.empty?
    end
  end

  show do
    attributes_table do
      row :full_name
      row :email
      row :phone
      row :zipcode
      row :city
      row :billing_info do
        bi = user.billing_info
        if bi
          "#{ bi.first_name } #{ bi.last_name } - #{ bi.card_type } ended in XXXX-XXXX-XXXX-#{ bi.last_four }, expires in #{ bi.month }/#{ bi.year }  "
        end
      end
      row :shipping_infos do
        if user.shipping_infos.any?
          ("<ul>" + \
          user.shipping_infos.map {|si| "<li>#{si.first_name} #{si.last_name} - #{si.pretty_address.join(' - ')}</li>" }.join(' ') + \
          "</ul>").html_safe
        end
      end
      row :subscriptions do
        if user.subscriptions.any?
          ("<ul>" + \
          user.subscriptions.map {|s| "<li><a href='/admin/subscriptions/#{s.id}'>##{s.id}:</a> #{s.plan.name} #{s.plan_recurrence.shipping_desc} - $#{s.plan_recurrence.amount} #{s.plan_recurrence.billing_desc}</li>" }.join(' ') + \
          "</ul>").html_safe
        end
      end
      row :invoices do
        if user.invoices.any?
          ("<ul>" + \
          user.invoices.map do |i|
            "<li>
              <a href='/admin/invoices/#{i.id}'>##{i.invoice_number}:</a>
              #{i.status} $#{i.total_in_usd}
              for subscription ##{i.subscriptions.any? ? i.subscriptions.first.id : 'Unknown'}
            </li>"
          end.join(' ') + "</ul>").html_safe
        end
      end
      row :refunds do
        if user.transactions.any?
          ("<ul>" + \
          user.transactions.map {|t| "<li><a href='/admin/refunds/#{t.id}'>##{t.id}:</a> Refunded $#{t.amount} from invoice ##{t.invoice.invoice_number}</li>" }.join(' ') + \
          "</ul>").html_safe
        end
      end
      row :adjustments do
        if user.adjustments.any?
          ("<ul>" + \
          user.adjustments.map {|a| "<li><a href='/admin/adjustments/#{a.id}'>##{a.id}:</a> #{a.adjustment_type} $#{a.amount_in_usd}</li>" }.join(' ') + \
          "</ul>").html_safe
        end
      end
      row :recurly_code
      row :is_active
      row :created_at
      row :last_sign_in_at
      row :last_sign_in_ip
    end
    active_admin_comments
  end

  member_action :mark_as_test, method: :put do
    @user = User.find(params[:id])
    @user.update_attribute(:is_test, true)
    redirect_to({ action: :index }, notice: "User ##{@user.id} marked as test user!")
  end

  member_action :mark_as_non_test, method: :put do
    @user = User.find(params[:id])
    @user.update_attribute(:is_test, false)
    redirect_to({ action: :index }, notice: "User ##{@user.id} marked as non-test user!")
  end

  action_item only: :show do
    String.new.tap do |content|
      activation_action = (user.is_active?)? 'De-activate' : 'Activate'

      content << link_to('Mark as test user', mark_as_test_admin_user_path(user), method: :put) unless user.is_test?
      content << link_to('Mark as non-test user', mark_as_non_test_admin_user_path(user), method: :put) if user.is_test?
      content << link_to(activation_action, toggle_admin_user_path(user), confirm: "Are you sure you want to #{activation_action} #{@user}?")
    end.html_safe
  end
end
