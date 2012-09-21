class StatisticsService

  MIN_STARTING_DATE = Date.civil(2012, 5, 31)

  class << self
    def last_years_subscriptions_and_income
      statistics_list = valid_periods

      statistics_list.each do |statistic_period|
        statistic_period[:subscriptions_number] = subscriptions_number(statistic_period[:date_from], statistic_period[:date_to])
        statistic_period[:income] = income(statistic_period[:date_from], statistic_period[:date_to])
      end

      statistics_list
    end

    def subscriptions_number(from, to)
      Subscription.where('subscriptions.created_at BETWEEN ? AND ?', from, to).non_test.count
    end

    def income(from, to)
      (Invoice.select('SUM(total_in_usd) as invoices_total').where('subscriptions.created_at BETWEEN ? AND ?', from, to).non_test.first.invoices_total || 0).to_i
    end

    def valid_periods
      current_date = Date.current
      previous_date = Date.civil(current_date.year, current_date.month, 1)
      date = (Date.civil(current_date.year, current_date.month, 1) + 1.month).to_date
      months = []
      while date > MIN_STARTING_DATE
        data = {
          date_from: previous_date,
          date_to: date,
          display: "#{Date::ABBR_MONTHNAMES[previous_date.mon]}/#{previous_date.year}"
        }
        date = previous_date
        previous_date -= 1.month
        months << data
      end

      months.reverse
    end
  end
end
