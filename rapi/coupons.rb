module Monthly
  module Rapi

    class Coupons
      # Coupons can't be updated so we just deactivate de current
      # and create a new one.
      def self.sync(coupon)
        if coupon.recurly_code.nil? || coupon.recurly_code.empty?
          recurly_code = Helpers.recurly_create_coupon(coupon)
        else
          recurly_code = Helpers.recurly_update_coupon(coupon)
        end

        coupon.tap do |c|
          c.recurly_code = recurly_code
          c.save(validate: false)
        end
      end

      module Helpers
        module_function

        def recurly_create_coupon(coupon)
          rcoupon = ::Recurly::Coupon.create!(coupon_recurly_params(coupon))
          rcoupon.coupon_code
        end

        def recurly_update_coupon(coupon)
          recurly_find_coupon(coupon).destroy
          recurly_create_coupon(coupon)
        end

        def recurly_find_coupon(coupon)
          ::Recurly::Coupon.find(coupon.recurly_code)
        end

        def get_recurly_plan_codes(coupon)
          coupon.plan_recurrences.map { |pr| pr.recurly_plan_code }
        end

        def coupon_recurly_params(coupon)
          valid_coupon_code = coupon.coupon_code.gsub(/[^\d\w_-]+/, '-')
          valid_coupon_code.gsub!(/-+/, '-')

          params = {
            coupon_code: Rapi::Utils.ucode(valid_coupon_code),
            discount_in_cents: Rapi::Utils.convert_to_cents(coupon.discount_in_usd)
          }

          [ :name, :invoice_description, :redeem_by_date, :single_use,
            :applies_for_months, :max_redemptions, :applies_to_all_plans,
            :discount_type, :discount_percent ].each do |f|
            v = coupon.send(f)
            params[f] = v unless v.nil?
          end

          unless coupon.applies_to_all_plans
            params[:plan_codes] = get_recurly_plan_codes(coupon)
          end

          params
        end

      end
    end

  end
end
