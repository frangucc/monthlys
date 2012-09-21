module BreadcrumbsHelper

  def breadcrumbs_for(object_type, object)
    breadcrumb = "#{link_to 'Home', root_path}"

    case object_type
    when :category_group
      breadcrumb << " <span class='separator'>/</span> #{object.name}"
    when :category
      if object.category_group
        breadcrumb << " <span class='separator'>/</span> "
        breadcrumb << link_to(object.category_group.name, category_group_path(object.category_group))
      end
      breadcrumb << " <span class='separator'>/</span> #{object.name}"
    when :plan
      if object.categories.any?
        category = object.categories.first
        category_group = category.category_group
        if category_group
          breadcrumb << " <span class='separator'>/</span> "
          breadcrumb << link_to(category_group.name, category_group_path(category_group))
        end
        breadcrumb << " <span class='separator'>/</span> "
        breadcrumb << link_to(category.name, category_path(category))
      end
      breadcrumb << " <span class='separator'>/</span> #{object.name}"
    when :tag
      breadcrumb << " <span class='separator'>/</span> #{object.keyword.capitalize}"
    when :superhub
      breadcrumb << ' <span class="separator">/</span> <span class="item">Superhubs</span>'
      breadcrumb << " <span class='separator'>/</span> #{object.verbose_name.capitalize}"
    when :my_account_section
      breadcrumb << " <span class='separator'>/</span> "
      breadcrumb << link_to('My Account', ms_path(subscriptions_path))
      breadcrumb << " <span class='separator'>/</span> #{object}"
    when :subscription
      breadcrumb << " <span class='separator'>/</span> "
      breadcrumb << link_to('My Account', ms_path(subscriptions_path))
      breadcrumb << " <span class='separator'>/</span> "
      breadcrumb << link_to('My Subscriptions', ms_path(subscriptions_path))
      if object.new_record?
        breadcrumb << ' <span class="separator">/</span> New'
      else
        breadcrumb << " <span class='separator'>/</span> #{object.plan.name}"
      end
    when :my_settings_section
      breadcrumb << " <span class='separator'>/</span> "
      breadcrumb << link_to('My Account', ms_path(subscriptions_path))
      breadcrumb << " <span class='separator'>/</span> "
      breadcrumb << link_to('My Settings', ms_path(edit_settings_path))
      breadcrumb << " <span class='separator'>/</span> #{object}"
    end

    breadcrumb.html_safe
  end
end
