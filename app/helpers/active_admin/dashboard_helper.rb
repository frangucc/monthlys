module ActiveAdmin::DashboardHelper

  def table_diff_helper(prev_attributes, new_attributes, verb)
    all_keys = (prev_attributes.keys | new_attributes.keys)

    content_tag(:table, class: 'index_table') do
      concat(content_tag(:thead)  do
               concat(content_tag(:tr) do
                        concat(content_tag :th, 'Field')
                        unless verb == 'create'
                          concat(content_tag :th, 'Before')
                        end
                        concat(content_tag :th, verb == 'create' ? 'Value' : 'After')
                      end)
             end)

      concat(content_tag(:tbody) do
               all_keys.each do |key|
                 concat(content_tag(:tr, class: cycle('odd', 'even')) do
                          concat(content_tag :th, key.to_s.humanize)
                          unless verb == 'create'
                            concat(content_tag :td, show_attribute(prev_attributes[key]))
                          end
                          concat(content_tag :td, show_attribute(new_attributes[key]))
                        end)
               end
             end)
    end
  end

  def show_attribute(attribute)
    if attribute.nil?
      '<span class="empty">Empty</span>'.html_safe
    elsif attribute.kind_of? Array
      attribute.empty? ? show_attribute(nil) : attribute.map {|a| show_attribute(a) }.join(', ').html_safe
    elsif attribute.kind_of? Hash
      "#{attribute[:desc]} (##{attribute[:id]})"
    else
      attribute
    end
  end

end
