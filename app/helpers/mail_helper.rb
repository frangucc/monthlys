module MailHelper
  def plan_recurrences_description(plan, plan_recurrences)
    # Sort by convenience and reverse, the first one is the most expensive option
    sorted_plan_recurrences = plan_recurrences.sort_by {|pr| pr.service_cost }.reverse
    first = sorted_plan_recurrences.first
    strategy = plan.upsell_strategy

    if strategy != :none
      # Populate a select
      options = sorted_plan_recurrences.map do |pr|
        label = pr.billing_cycle.inspect

        # Add savings percentage
        savings = 100 - (pr.service_cost * 100 / first.service_cost).to_i
        save = (pr != first && !savings.zero?)? savings : nil

        [ pr, label, save ]
      end
    end
  end
end
