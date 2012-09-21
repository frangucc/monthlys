ActiveAdmin.register_page 'Statistics' do

  menu parent: 'Marketing'

  content do
    ########################################################################
    # Charts data
    ########################################################################
    chart_statistics = StatisticsService.last_years_subscriptions_and_income
    subscriptions_avg = chart_statistics.inject(0) {|total, s| total + s[:subscriptions_number] } / chart_statistics.count
    income_avg = chart_statistics.inject(0) {|total, s| total + s[:income] } / chart_statistics.count

    ############################################################################
    # Search specific statistics
    ############################################################################
    search_params = (params[:search] || {}).reject {|_, v| v.blank? }
    from_date = search_params.fetch(:from_date, 1.week.ago).to_date
    to_date = search_params.fetch(:to_date, Date.current).to_date
    statistics_hash = {}

    plans_scope = Plan.where('plans.created_at BETWEEN ? AND ?', from_date, to_date)
    subscriptions_scope = Subscription.unscoped.where('subscriptions.created_at BETWEEN ? AND ?', from_date, to_date).non_test
    friends_scope = Friend.where('friends.created_at BETWEEN ? AND ?', from_date, to_date)
    newsletter_subscribers_scope = NewsletterSubscriber.where('newsletter_subscribers.created_at BETWEEN ? AND ?', from_date, to_date)
    transactions_scope = Transaction.where('transactions.created_at BETWEEN ? AND ?', from_date, to_date)
    merchants_scope = Merchant.where('merchants.created_at BETWEEN ? AND ?', from_date, to_date)
    users_scope = User.where('users.created_at BETWEEN ? AND ?', from_date, to_date).non_test
    invoices_scope = Invoice.where('invoices.created_at BETWEEN ? AND ?', from_date, to_date).non_test
    preferences_scope = UserPreference.where('user_preferences.created_at BETWEEN ? AND ?', from_date, to_date).non_test

    # Count totals
    statistics_hash['Total subscriptions'] = subscriptions_scope.count
    statistics_hash['Total gift subscriptions'] = subscriptions_scope.where(is_gift: true).count

    # 3, 6 or 12 month subscriptions number
    valid_recurrences = Recurrence::RECURRENCES.select {|_, v| v[:monthly_cost].call(1) < 1 }.keys
    valid_plan_recurrences_ids = PlanRecurrence.select(:id).where(recurrence_type: valid_recurrences).all.map(&:id)

    statistics_hash['Total 3, 6 or 12 month subscriptions number'] =
      subscriptions_scope.where(plan_recurrence_id: valid_plan_recurrences_ids).count

    # Organic sales (without coupon)
    statistics_hash['Total organic sales (without coupon)'] =
      subscriptions_scope.where(redemption_id: nil).count

    # Invoices total
    statistics_hash['Invoices sum total'] =
      (invoices_scope.select('SUM(total_in_usd) as sum_total_in_usd').first.sum_total_in_usd || 0).to_i.round(2)

    # Top 10 plans sold
    result = ActiveRecord::Base.connection.execute("
      SELECT plan_recurrences.plan_id, COUNT(*) as subscriptions_count
      FROM subscriptions
      INNER JOIN plan_recurrences
        ON subscriptions.plan_recurrence_id = plan_recurrences.id
      WHERE subscriptions.id IN (#{subscriptions_scope.any? ? subscriptions_scope.all.map(&:id).join(', ') : 'NULL'})
      GROUP BY plan_recurrences.plan_id
      ORDER BY subscriptions_count DESC
      LIMIT 10
    ").to_a

    statistics_hash['Top 10 plans'] = result.map do |row_data|
      plan = Plan.find(row_data['plan_id'])
      "#{plan.name} (#{row_data['subscriptions_count']} subscribers)"
    end.join(', ')

    # Friends
    statistics_hash['Friends invited'] = friends_scope.count

    # Users which created user preferences
    statistics_hash['Users with new user preferences'] = preferences_scope.select('user_preferences.user_id').map(&:user_id).uniq.count

    # Newsletter subscribers
    statistics_hash['Newsletter subscribers'] = newsletter_subscribers_scope.count

    # Refunds
    statistics_hash['Refunds made'] = transactions_scope.where(action: 'refund').count

    # Emails captured
    statistics_hash['Emails captured this week'] =
      newsletter_subscribers_scope.count + friends_scope.count + users_scope.count

    # New plans
    statistics_hash['New plans'] = plans_scope.count

    # New merchants
    statistics_hash['New merchants'] = merchants_scope.count

    # Pricing averages and totals
    statistics_hash['Subscriptions recurrent total average'] =
      (subscriptions_scope.select('AVG(recurrent_total) as avg_recurrent_total').first.avg_recurrent_total || 0).to_i.round(2)
    statistics_hash['Subscriptions recurrent total sum'] =
      (subscriptions_scope.select('SUM(recurrent_total) as sum_recurrent_total').first.sum_recurrent_total || 0).to_i.round(2)
    statistics_hash['Subscriptions first time total average'] =
      (subscriptions_scope.select('AVG(first_time_total) as avg_first_time_total').first.avg_first_time_total || 0).to_i.round(2)
    statistics_hash['Subscriptions first time discount average'] =
      (subscriptions_scope.select('AVG(first_time_discount) as avg_first_time_discount').first.avg_first_time_discount || 0).to_i.round(2)
    statistics_hash['Subscriptions first time discount sum'] =
      (subscriptions_scope.select('SUM(first_time_discount) as sum_first_time_discount').first.sum_first_time_discount || 0).to_i.round(2)

    render partial: 'admin/statistics/index', locals: {
      statistics_hash: statistics_hash,
      search: { from_date: from_date, to_date: to_date },

      # Charts
      chart_statistics: chart_statistics,
      subscriptions_avg: subscriptions_avg,
      income_avg: income_avg
    }
  end
end
