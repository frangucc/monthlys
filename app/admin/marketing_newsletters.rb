ActiveAdmin.register Marketing::Newsletter do

  menu parent: 'Marketing'

  index do
    column :id
    column :subject
    column :heading
    column :plan
    column :coupon
    column :preview do |marketing_newsletter|
      link_to 'Preview', marketing_newsletter_path(marketing_newsletter), target: '_blank'
    end
    default_actions
  end

  form do |f|
    f.inputs "Basics area" do
      f.input :subject
      f.input :heading
      f.input :subheading
      f.input :main_content, hint: 'Markdown is allowed in this field.'
      f.input :main_image, hint: 'Image will be resized to be 560px wide. Height will be proportional to that.'
      f.input :main_image_link, hint: 'URL for the main image link'
    end

    f.inputs "SINGLE Featured Plan and Coupon area" do
      f.input :plan, as: :select, collection: Plan.has_status(:active).all.map {|p| [p.name, p.id] }
      f.input :coupon, as: :select, collection: Coupon.active.all.map {|c| ["#{c.coupon_code} - #{c.name}", c.id] }
      # Overrrides
      f.input :the_value, hint: 'Defaults to the plan\'s short description.'
      f.input :featured_price, hint: 'Defaults to the price of the plan\'s most convenient plan recurrence'
      f.input :featured_billing_cycle, hint: 'Defaults to the billing cycle of the plan\'s most convenient plan recurrence'
      f.input :footnote, hint: 'Defaults to an explanation of the plan\'s most convenient plan recurrence'
    end

    f.inputs "MULTIPLE Featured Plans and Coupons area" do
      f.input :best_sellers
    end

    f.inputs "Three-block area" do
      # First Block
      f.input :first_block_heading
      f.input :first_block_link
      f.input :first_block_description
      f.input :first_block_image
      # Second Block
      f.input :second_block_heading
      f.input :second_block_link
      f.input :second_block_description
      f.input :second_block_image
      # Third Block
      f.input :third_block_heading
      f.input :third_block_link
      f.input :third_block_description
      f.input :third_block_image
    end

    f.inputs "Getting Started area" do
      f.input :show_getting_started_steps
    end

    f.buttons
  end

  show do
    attributes_table do
      row :subject
      row :heading
      row :subheading
      row :main_content
      row :main_image
      row :main_image_link
      row :plan
      row :coupon
      row :the_value
      row :featured_price
      row :featured_billing_cycle
      row :footnote
      row :first_block_heading
      row :first_block_link
      row :first_block_description
      row :first_block_image
      row :second_block_heading
      row :second_block_link
      row :second_block_description
      row :second_block_image
      row :third_block_heading
      row :third_block_link
      row :third_block_description
      row :third_block_image
      row :show_getting_started_steps

      row :preview do
        link_to 'Preview', marketing_newsletter_path(marketing_newsletter), target: '_blank'
      end

      row :get_code_for_exact_target do
        link_to 'Get Code', marketing_newsletter_path(marketing_newsletter, format: :text), target: '_blank'
      end
    end
    active_admin_comments
  end

end
