ActiveAdmin::Dashboards.build do

  section 'Recent Subscriptions' do
    ul do
      Subscription.includes(:plan, :user).order('subscriptions.created_at DESC').limit(10).collect do |subscription|
        li do
          link_to(subscription.plan.name, admin_subscription_path(subscription)) + \
          " - #{subscription.user.email} - #{time_ago_in_words(subscription.created_at)} ago"
        end
      end
    end
  end

  section 'Recent Admin Activity', priority: 11 do
    ul(class: 'admin-activity') do
      AdminActivity.latest.all.each do |admin_activity|
        resource_path = send("admin_#{admin_activity.object_type.underscore}_path", admin_activity.object) if admin_activity.object
        content_str = "
          <div class=\"activity-info\">
            <p>
              <strong>
                #{admin_activity.verb.upcase}:
              </strong>
              #{admin_activity.object ? link_to(admin_activity.object_type, resource_path) : admin_activity.object_type}
              ##{admin_activity.object_id}
              (by <strong>#{admin_activity.admin_user.email}</strong>) - #{time_ago_in_words(admin_activity.created_at)} ago
            </p>
          </div>
        "


        unless admin_activity.previous_attributes.size == 0 && admin_activity.new_attributes.size == 0
          content_str << table_diff_helper(admin_activity.previous_attributes,
                                           admin_activity.new_attributes,
                                           admin_activity.verb)
        end
        li content_str.html_safe
      end
    end
  end

  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end

  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end
