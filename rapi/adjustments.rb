module Monthly
  module Rapi

    class Adjustments
      def self.create(adjustment)
        uuid = Helpers.recurly_create_adjustment(adjustment)
        adjustment.recurly_code = uuid
        adjustment.save(validate:false)
      end

      module Helpers
        module_function

        def recurly_create_adjustment(adjustment)
          raccount = ::Recurly::Account.find(adjustment.user.recurly_code)
          radjustment = raccount.adjustments.create(adjustment_recurly_params(adjustment))
          raccount.invoice! unless adjustment.adjustment_type == 'credit'
          radjustment.uuid
        end

        def adjustment_recurly_params(adjustment)
          amount = adjustment.amount_in_usd
          amount *= -1 if adjustment.adjustment_type == 'credit'

          p amount.to_s
          { description: adjustment.description,
            unit_amount_in_cents: Rapi::Utils.convert_to_cents(amount) }
        end

      end
    end

  end
end
