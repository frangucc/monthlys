module PlansHelper

  include FiltersHelper

  def drop_down_options(option_group, plan_recurrence)
    option_group.options.active.collect do |option|
      price_desc = if option_group.nocharge? || option.amount.zero?
        'No additional charges'
      elsif option_group.onetime?
        "Add $ #{pretty_price(option.amount)} (one time fee)"
      elsif option_group.per_service? || option_group.per_billing?
        "Add $ #{pretty_price(option.amount_per_billing(plan_recurrence))} #{plan_recurrence.billing_desc}"
      end
      [option.title, option.id, { 'data-price-desc' => price_desc } ]
    end
  end

  def plan_recurrences_drop_down(plan, plan_recurrences, selected_plan_recurrence)
    # Sort by convenience and reverse, the first one is the most expensive option
    sorted_plan_recurrences = plan_recurrences.sort_by {|pr| pr.service_cost }.reverse

    expensive_pr = sorted_plan_recurrences.first
    strategy = plan.upsell_strategy
    input = ''
    input_label = nil

    if strategy == :none
      # Inform about the only shipping/billing recurrence available
      input = hidden_field_tag(:plan_recurrence_id, expensive_pr.id)
    else
      # Set the label
      if strategy == :per_time_commitment
        input_label = label_tag(:plan_recurrence_id, 'Subscribe and Save')
      elsif strategy == :per_number_of_services
        input_label = label_tag(:plan_recurrence_id, 'Frequency')
      end

      # Populate a select
      options = sorted_plan_recurrences.map do |pr|
        label = case strategy
                when :per_number_of_services then "#{pr.shipping_desc} for $#{pr.pretty_amount}#{pr.billing_desc}"
                when :per_time_commitment then "#{pr.billing_cycle_in_words} plan - #{sprintf('%.02f', pr.monthly_cost)} /month"
                end

        # Add savings percentage
        savings = 100 - (pr.service_cost * 100 / expensive_pr.service_cost).to_i
        save = (pr != expensive_pr && !savings.zero?)? "Save #{savings}%" : nil

        [label, pr.id, { 'data-save' => save } ]
      end

      input = select_tag(:plan_recurrence_id, options_for_select(options, selected_plan_recurrence.id))
    end

    { input: input, label: input_label, has_multiple_options: strategy != :none }
  end
end
