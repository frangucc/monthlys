require mp_path('mp/forms/base')

module MP
  module Forms
    class CouponForm < Form
      string :coupon_code
      string :name
      text :marketing_description, required: false
      text :invoice_description, required: false
      file :image, label: 'Image',
                   required: false,
                   widget: Bureaucrat::Widgets::ImageInput,
                   help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
      field :redeem_by_date, Bureaucrat::Fields::DateField.new
      integer :applies_for_months, required: false
      integer :max_redemptions, required: false
      choice :discount_type, [['percent', 'Percentage'],
                              ['dollars', 'Amount in dollars']]
      integer :discount_percent , required: false
      decimal :discount_in_usd , required: false, label: 'Discount in USD'
      boolean :single_use, label: 'Single use?', required: false
      boolean :applies_to_all_plans, label: 'Applies to all plans?', required: false
      boolean :is_active, label: 'Is active?', required: false

      def clean_discount_in_usd
        case @cleaned_data['discount_type']
        when 'dollars'
          @cleaned_data['discount_in_usd']
        when 'percent'
          nil
        end
      end

      def clean_discount_percent
        case @cleaned_data['discount_type']
        when 'percent'
          @cleaned_data['discount_percent']
        when 'dollars'
          nil
        end
      end
    end
  end
end
