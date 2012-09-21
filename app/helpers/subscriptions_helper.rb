module SubscriptionsHelper

  def subscription_explanation(plan_recurrence, billing_info)
    content_tag(:p) do
      "
        <strong>#{plan_recurrence.pretty_explanation}</strong> 
        will be debited from the card ending in #{billing_info.last_four} 
      ".html_safe
    end
  end
end
