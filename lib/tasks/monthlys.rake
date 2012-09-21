namespace :monthlys do

  # Plans-related tasks
  namespace :plans do
    task :sync_recurly_plans => :environment do
      ActiveSupport::Deprecation.warn "Use rapi:sync:plans instead!"
      Rake::Task["rapi:sync:plans"].invoke
    end

    task :desync_recurly_plans => :environment do
      ActiveSupport::Deprecation.warn "Use rapi:clear:plans instead!"
      Rake::Task["rapi:clear:plans"].invoke
    end
  end

  # Subscriptions-related tasks
  namespace :subscriptions do
    desc "Update subscription's next shipping date and shipping status"
    task :update_shipping_date_and_status => :environment do
      # TODO: Figure out how to filter out subscriptions where the
      # last_paid_service_date < Date.current.
      Subscription.active_shipping.includes(:plan_recurrence).find_each do |s|
        puts "Updating #{s.id}"

        if s.shippable?
          s.next_shipping_date = s.get_next_shipping_date
        end

        s.shipping_status = if s.last_paid_service_date > Date.current
          "active"
        else
          "inactive"
        end

        s.save if s.changed?
      end
    end
  end

  # User-related tasks
  namespace :users do
    task :desync_recurly_accounts do
      ActiveSupport::Deprecation.warn "Use rapi:clear:accounts instead!"
      Rake::Task["rapi:clear:accounts"].invoke
    end

    task :sync_recurly_accounts do
      ActiveSupport::Deprecation.warn "Use rapi:sync:accounts instead!"
      Rake::Task["rapi:sync:accounts"].invoke
    end

    desc "Resave Users"
    task :resave => :environment do
      User.find_each(&:save)
    end
  end

  namespace :reports do
    namespace :subscriptions do

      desc 'Check subscription freezed fields'
      task :frozen_fields => :environment do

        # TODO: Take into account adjustments and their effect on the next invoice on the timeline
        # TODO: Create the pending charges and credits before running this task on prod (See subscription #254)

        all_errors = Hash.new { |h,k| h[k] = [] }

        Subscription.includes(:invoices).find_each do |s|
          invoices = s.invoices.all.sort_by {|i| i.invoice_number }
          first_invoice = invoices.first
          last_invoice = invoices.last
          errors = []

          if !last_invoice
            errors << [ :noinvoice, 'No invoice associated' ]
          else
            if first_invoice.total_in_usd != s.first_time_total
              errors << [ :first_total_invoice_total,
                          "first_time_total doesn't match first invoice total",
                          [ [ 'Subscription first_time_total', "$#{s.first_time_total}" ],
                            [ 'Subscription recurrent_total', "$#{s.recurrent_total}" ],
                            [ 'Subscription onetime_total', "$#{s.onetime_total}" ],
                            [ 'Subscription first_time_discount', "$#{s.first_time_discount}" ],
                            [ 'Subscription shipping_amount', "$#{s.shipping_amount}" ],
                            [ 'Subscription recurrent_tax_amount', "$#{s.recurrent_tax_amount}" ],
                            [ 'First invoice total', "$#{first_invoice.total_in_usd}" ] ] ]
            end
            if last_invoice != first_invoice
              if last_invoice.total_in_usd != s.recurrent_total
                errors << [ :recurrent_invoice_subtotal,
                            "recurrent_total doesn't match non-first invoice total",
                            [ [ 'Subscription recurrent_total', "$#{s.recurrent_total}" ],
                              [ 'Last invoice total', "$#{last_invoice.total_in_usd}" ] ] ]
              end
            else
              if first_invoice.subtotal_in_usd != s.recurrent_total + s.onetime_total
                errors << [ :recurrent_invoice_subtotal,
                            "recurrent_total+onetime_total doesn't match first invoice subtotal",
                            [ [ 'Subscription recurrent_total', "$#{s.recurrent_total}" ],
                            [ 'Subscription first_time_discount', "$#{s.first_time_discount}" ],
                              [ 'Subscription onetime total:', "$#{s.onetime_total}" ],
                              [ 'Subscription shipping_amount', "$#{s.shipping_amount}" ],
                              [ 'First invlice subtotal', "$#{first_invoice.subtotal_in_usd}" ] ] ]
              end

            end
          end

          unless errors.empty?
            puts "\nErrors on subscription: #{s.id} (#{s.recurly_code})"
            errors.each do |e|
              puts "   * #{e[1]}"
              if e[2] && e[2].any?
                puts "     VALUES:"
                e[2].each { |desc, val| puts "       #{desc}: #{val}" }
              end
              all_errors[e[0]] << e[1]
            end
          end
        end

        puts '---------------------------------------------------------'
        puts "SUMMARY:"
        all_errors.each do |k, msg|
          puts "#{all_errors[k].size}: #{all_errors[k][0]}"
        end
      end

    end

    desc 'Verify if all coupons are synched'
    task :verify_coupons_sync => :environment do
      Coupon.find_each do |coupon|
        next if coupon.expired?

        if coupon.recurly_code.blank? || !(Recurly::Coupon.find(coupon.recurly_code) rescue nil)
          puts "Coupon ##{coupon.id} with coupon code '#{coupon.coupon_code}' is not synched with Recurly"
        end
      end
    end

    desc 'Count number of invoices for a user in our app and in Recurly'
    task :count_invoices => :environment do
      subscription_recurly_codes = %w(1a0b42a9437a40e58b2a3c430aba7e4c 1a0a5477927b6f453363844a76bc9e40 1a0a53ef9eea322d7884814a62bebd04 1a0a2ac7578c65b5f1232947aeaaca8b 1a0a10b792ed0e50d8bff54ea9b7deef 1a09ffc3f5424e7ecf96234b8aaed623 1a09d32f34ebe85d2c661443ceb70a08 1a09b8eba9a0e89d6e96c84f3fbaed65 1a10522fba1f6ddaf27ac342b3800991 1a101a70cc92685441e3c74636935e4b 1a0ffaabc1076d740f1add4054acb7eb 1a0f9b5eb15e6e446398ad41d7abfb25 1a0f83d8fcf86139e3c1dc469bb52a01 1a0f7f753df302edacbaad4fcabbc909 1a0f574e193c0fb99c26b84648b570b6 1a0bfdb317a16269f2354e4829b45b46 1a0bd0428a1d691e02d8dd4df9bc7294 1a0bc71be9ae6b39a49d214f14981700 1a0baa400ab83f92ff41d441ba906051 1a1508134032403f27acea4af1816fa3 1a14167c75635b6630e4844c29884d81 1a13d46a0667a6ba6342f24933af4d78 1a13bda667467594322d1342f5991df6 1a13954f6232462f9d570f4886b3a2f0 1a13612d3b8a85d9977f5a4426bd51bf 1a1338dd977f54d28e937943d086b432 1a12a28396606200bc44214e45bdf8e6 1a10defa37a02a7e9cae2d42569fc657 1a1a8d50f964d21dab46b2437fa57d36)

      Subscription.where(recurly_code: subscription_recurly_codes).find_each do |subscription|
        user = subscription.user
        ruser = Recurly::Account.find(user.recurly_code)

        invoices = user.invoices.count
        rinvoices = ruser.invoices.count

        if invoices == rinvoices
          puts "User ##{user.id} invoices match"
        else
          puts "Error: User ##{user.id} invoices don't match. Invoices: #{invoices}. Rinvoices: #{rinvoices}"
        end
      end
    end
  end

  # Utilities
  namespace :utilities do

    desc 'Postpone renewal dates for certain subscriptions'
    task :postpone_renewal_dates => :environment do
      pp_date = # Date
      subscription_recurly_codes = # Array of subscription recurly codes

      Subscription.where(recurly_code: subscription_recurly_codes).find_each do |subscription|
        puts "Updating ##{subscription.id}"
        subscription.update_attribute(:renewal_date, pp_date)
        rsubscription = Recurly::Subscription.find(subscription.recurly_code)
        rsubscription.postpone(pp_date)
      end
    end

    desc 'Mass creation of totsy coupons'
    task :create_totsy_coupons, [:count] => :environment do |t, args|
      plan = Plan.find_by_slug('m-nage-trois-flavored-coffee-trio')
      abort 'Error: Plan not found' unless plan
      abort 'Error: Pass the amount of coupons to create' unless args[:count]

      count = args[:count].to_i
      (1..count).each do
        coupon_code = 'TOT-' + SecureRandom.urlsafe_base64(4).upcase.gsub(/[-_0O]/, 'X')
        redo if Coupon.find_by_coupon_code(coupon_code)

        desc = "Totsy Peter Asher Discount - #{coupon_code}"
        c = Coupon.create(coupon_code: coupon_code,
                          name: desc,
                          marketing_description: desc,
                          invoice_description: desc,
                          redeem_by_date: Date.new(2012, 11, 26),
                          applies_for_months: 1,
                          discount_type: 'dollars',
                          discount_in_usd: 25,
                          is_active: true,
                          applies_to_all_plans: false,
                          max_redemptions: 1,
                          available_to_all_users: true,
                          plans: [plan])
        Monthly::Rapi::Coupons.sync(c)

        puts "#{c.coupon_code} (#{c.id})"
      end
    end
  end

  # Temporal Tasks
  desc 'Turn back on emails'
  task :turn_back_on_strategy => :environment do
    users_notified_ids = []
    Subscription.includes(:user, plan_recurrence: :plan).has_state(:expired, :canceled).find_each do |subscription|
      user = subscription.user
      plan = subscription.plan

      next if users_notified_ids.include?(user.id)
      next unless plan.active?
      next if user.subscriptions.includes(:plan_recurrence).has_state(:active).where(plan_recurrences: { plan_id: plan.id }).where('subscriptions.id != ?', subscription.id).any?

      users_notified_ids << user.id

      Resque.enqueue(ReactivateEmailJob, subscription.id)
    end

    puts users_notified_ids.inspect
  end

  desc 'Update past_due subscriptions'
  task :update_past_due_subscriptions => :environment do
    total_past_due = 0
    Subscription.includes(:invoices).find_each do |subscription|
      invoices = subscription.invoices.sort_by {|i| i.invoice_number }
      last_invoice = invoices.last

      if last_invoice
        puts "Subscription: ##{subscription.id}. Monthly status: '#{subscription.state}'. Last invoice status: '#{last_invoice.status}.'"
      else
        puts "Subscription: ##{subscription.id}. Doesn't have invoices!"
        next
      end

      if subscription.expired?
        if last_invoice.status == 'failed'
          subscription.update_attribute(:is_past_due, true)
          total_past_due += 1
        elsif last_invoice.status == 'past_due'
          puts 'Weird case (?)'
        end
      else
        if last_invoice.status == 'past_due'
          subscription.update_attribute(:is_past_due, true)
          total_past_due += 1
        elsif last_invoice.status == 'collected'
          subscription.update_attribute(:is_past_due, false)
        end
      end
    end
    puts 'Past due update finished successfully.'
    puts "Total updated past_due subscriptions: #{total_past_due}"
  end

  desc 'Populate expired_at'
  task :populate_expired_at => :environment do
    Subscription.has_state(:expired).find_each do |subscription|
      rsubscription = Recurly::Subscription.find(subscription.recurly_code)
      puts "Updating subscription ##{subscription.id}. Expired at: #{rsubscription.expires_at.inspect}."
      if rsubscription.state != 'expired'
        puts 'ERROR: this subscription is not expired according to recurly!'
        next
      end
      subscription.update_attribute(:expired_at, rsubscription.expires_at)
    end
  end

  desc 'Populate canceled_at'
  task :populate_canceled_at => :environment do
    Subscription.has_state(:canceled, :expired).find_each do |subscription|
      rsubscription = Recurly::Subscription.find(subscription.recurly_code)
      puts "Updating subscription ##{subscription.id}. Canceled at: #{rsubscription.canceled_at.inspect}."
      if !rsubscription.canceled_at
        puts 'This subscription was not canceled'
        next
      end
      subscription.update_attribute(:canceled_at, rsubscription.canceled_at)
    end
  end

  desc 'Populate last_payment fields on subscriptions'
  task :populate_last_payment_fields => :environment do
    Subscription.find_each do |subscription|
      last_paid_invoice = subscription.last_paid_invoice

      puts "Updating subscription ##{subscription.id}"
      puts " - last payment date                   #{last_paid_invoice.created_at}"
      puts " - last payment amount                 #{last_paid_invoice.total_in_usd}"

      subscription.last_payment_date = last_paid_invoice.created_at
      subscription.last_payment_amount = last_paid_invoice.total_in_usd
      subscription.save(validate: false)
    end
  end

  desc 'Populate current_period_started_at and current_period_ends_at'
  task :populate_subscription_period_fields => :environment do
    Subscription.find_each do |subscription|
      Monthly::Rapi::Subscriptions.update_current_period(subscription)
    end
  end

  desc 'Run subscriptions date reports'
  task :subscriptions_date_reports => :environment do
    Subscription.find_each do |subscription|
      rsubscription = Recurly::Subscription.find(subscription.recurly_code)

      puts "-- Checking Subscription ##{subscription}"
      if subscription.state != rsubscription.state
        puts "
          STATE DOESN'T MATCH WITH RECURLY's.
          Recurly  state: #{rsubscription.state}.
          Monthlys state: #{subscription.state}.
        "
      end

      if subscription.current_period_started_at != rsubscription.current_period_started_at
        puts "
          STARTED_AT DOESN'T MATCH WITH RECURLY's.
          Recurly  started at: #{rsubscription.current_period_started_at}.
          Monthlys started at: #{subscription.current_period_started_at}.
        "
      end
      if subscription.created_at.to_date != rsubscription.activated_at.to_date
        puts "
          CREATED_AT DOESN'T MATCH WITH RECURLY's.
          Recurly  started at: #{rsubscription.current_period_started_at.to_date}.
          Monthlys started at: #{subscription.current_period_started_at}.
        "
      end
      if subscription.current_period_ends_at != rsubscription.current_period_ends_at
        puts "
          PERIOD DOESN'T MATCH WITH RECURLY's.
          Recurly  ends at: #{rsubscription.current_period_ends_at}.
          Monthlys ends at: #{subscription.current_period_ends_at}.
        "
      end
      if subscription.canceled? && subscription.canceled_at != rsubscription.canceled_at
        puts "
          CANCELED_AT DOESN'T MATCH WITH RECURLY's.
          Recurly  canceled_at: #{rsubscription.canceled_at}.
          Monthlys canceled_at: #{subscription.canceled_at}.
        "
      end
      if subscription.expired? && subscription.expired_at != rsubscription.expires_at
        puts "
          EXPIRED_AT DOESN'T MATCH WITH RECURLY's.
          Recurly  expires_at: #{rsubscription.expires_at}.
          Monthlys expired_at: #{subscription.expired_at}.
        "
      end
    end
  end

  desc 'Run subscriptions date reports'
  task :show_possible_terminated_subscriptions => :environment do
    Subscription.has_state(:active, :canceled).where(shipping_status: 'inactive').each do |subscription|
      rsubscription = Recurly::Subscription.find(subscription.recurly_code)
      refunds_count = subscription.invoices.map {|i| i.transactions.count }.inject(0, &:+)
      puts "Subscription ##{subscription.id}."
      puts " - Monthly state: #{subscription.state}."
      puts " - Recurly state: #{rsubscription.state}."
      puts " - # of refunds: #{refunds_count}"
    end
  end

  desc 'Convert old csv format to new'
  task :convert_old_csv_shipments_format => :environment do
    require 'csv'
    CSV.open('new_format.csv', 'wb') do |csv|
      csv << ['Subscription ID', 'Carrier', 'Tracking Number']

      CSV.foreach('old_format.csv') do |row|
        plan_name = row[0]
        user_email = row[1]
        carrier = row[2]
        tracking_number = row[3]

        user = User.find_by_email(user_email)
        unless user
          puts "User with email #{user_email} does not exist."
          next
        end

        possible_subscriptions = user.subscriptions.includes(plan_recurrence: :plan).where(plan_recurrences: { plan_id: 233 }).all

        if possible_subscriptions.empty? || possible_subscriptions.count > 1
          puts "Invalid number of subscriptions associated with user ##{user.id}: #{possible_subscriptions.count}."
          next
        end

        subscription = possible_subscriptions.first

        csv << [subscription.id, carrier, tracking_number]
      end
    end
  end

  desc 'Populate activated_at field on plans'
  task :populate_activated_at => :environment do
    Plan.find_each do |plan|
      plan.update_attribute(:activated_at, plan.created_at.to_date)
    end
  end
end
