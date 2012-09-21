require_relative 'utils.rb'

module Monthly
  module Rapi

    class Plans
      # Assumes Plans (and its recurrences) are saved on the db (id is available).
      # plan should eager load recurrences, option groups and options.
      def self.sync(plan)
        plan.plan_recurrences.each do |pr|
          Helpers.sync_plan_recurrence(plan_recurrence: pr, plan: plan)
        end

        plan
      end

      module Helpers
        module_function

        def sync_plan_recurrence(options)
          pr = options.fetch(:plan_recurrence)
          plan = options.fetch(:plan){ pr.plan }

          ropts = plan_recurly_params(pr, plan)

          if pr.recurly_plan_code.blank?
            plan_code = Rapi::Utils.ucode("#{plan.id}-#{pr.id}")
            ropts.merge!({ plan_code: plan_code,
                           accounting_code: plan_code })
            rplan = ::Recurly::Plan.create!(ropts)

            sync_shipping(plan, rplan)
            sync_taxes(plan, rplan)

            pr.recurly_plan_code = rplan.plan_code
            pr.save(validate: false)
          else
            rplan = ::Recurly::Plan.find(pr.recurly_plan_code)
            ropts.merge!({ accounting_code: rplan.plan_code })
            rplan.update_attributes!(ropts)
          end

          sync_addons(pr, rplan, plan: plan)
        end

        def sync_addons(pr, rplan, options)
          plan = options.fetch(:plan){ pr.plan }

          addons = plan.options.includes(:option_group).select do |o|
            o.option_group.per_service? || o.option_group.per_billing?
          end

          rcodes = {}
          pr.option_recurly_codes.each do |prc|
            rcodes[prc.option_id] = prc.recurly_code
          end

          addons.each do |addon|
            rparams = addon_recurly_params(addon)
            if rcodes[addon.id].nil?
              addon_rcode = Rapi::Utils::ucode(
                "#{pr.recurly_plan_code.rpartition('-')[0]}-#{addon.id}"
              )

              rplan.add_ons.create!(rparams.merge(add_on_code: addon_rcode))

              addon.option_recurly_codes.new(
                plan_recurrence: pr,
                recurly_code: addon_rcode
              ).save(validate: false)
            else
              rplan.add_ons.find(rcodes[addon.id]).update_attributes!(rparams)
            end
          end
        end

        def sync_shipping(plan, rplan)
          rplan.add_ons.create!({
            add_on_code: 'shipping',
            name: "Shipping",
            unit_amount_in_cents: 0
          })
        end

        def sync_taxes(plan, rplan)
          rplan.add_ons.create!({
            add_on_code: 'tax',
            name: "Taxes",
            unit_amount_in_cents: 0
          })
        end

        def plan_recurly_params(plan_recurrence, plan)
          recurrence = Recurrence.get(plan_recurrence.recurrence_type)
          {
            unit_amount_in_cents: Rapi::Utils::convert_to_cents(plan_recurrence.amount),
            name: "#{plan.name} (#{recurrence[:name]})",
            plan_interval_length: recurrence[:billing_interval_length],
            plan_interval_unit: recurrence[:billing_interval_unit],
          }
        end

        def addon_recurly_params(addon)
          {
            name: "#{addon.title}",
            unit_amount_in_cents: Rapi::Utils::convert_to_cents(addon.amount),
          }
        end

      end

    end
  end
end
