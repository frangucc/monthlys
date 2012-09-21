class Recurrence
  RECURRENCES = {
      daily: {
        name: 'Ship daily, bill monthly',
        shipping_desc: ' every day',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 30,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/30 }
      },
      weekly: {
        name: 'Ship weekly, bill monthly',
        shipping_desc: ' every week',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 4,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/4 }
      },
      weekly_annually: {
        name: 'Ship weekly, bill annually',
        shipping_desc: ' every week',
        billing_desc: '/year',
        billing_recurrence: 'yearly',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 48,
        monthly_cost: lambda {|amount| amount/12 },
        service_cost: lambda {|amount| amount/48 }
      },
      twice_a_week: {
        name: 'Ship twice a week, bill monthly',
        shipping_desc: ' twice a week',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 8,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/8 }
      },
      otherday: {
        name: 'Ship 3 days a week, bill monthly',
        shipping_desc: ' 3 days a week',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 12,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/12 }
      },
      four_days_a_week: {
        name: 'Ship 4 days a week, bill monthly',
        shipping_desc: ' 4 days a week',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 16,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/16 }
      },
      five_days_a_week: {
        name: 'Ship 5 days a week, bill monthly',
        shipping_desc: ' 5 days a week',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 20,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/20 }
      },
      every_two_weeks: {
        name: 'Ship every two weeks, bill monthly',
        shipping_desc: ' every two weeks',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 2,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/2 }
      },
      every_two_weeks_bill_quarterly: {
        name: 'Ship every two weeks, bill every 3 months',
        shipping_desc: ' every two weeks',
        billing_desc: '/quarter',
        billing_recurrence: 'quarterly',
        billing_interval_unit: 'months',
        billing_interval_length: 3,
        services_per_billing_cycle: 6,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/6 }
      },
      every_two_weeks_bill_semi_annually: {
        name: 'Ship every two weeks, bill every 6 months',
        shipping_desc: ' every two weeks',
        billing_desc: '/6 months',
        billing_recurrence: 'semi anually',
        billing_interval_unit: 'months',
        billing_interval_length: 6,
        services_per_billing_cycle: 12,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/12 }
      },
      every_two_weeks_bill_annually: {
        name: 'Ship every two weeks, bill annually',
        shipping_desc: ' every two weeks',
        billing_desc: '/year',
        billing_recurrence: 'anually',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 24,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount/24 }
      },
      monthly: {
        name: 'Ship/bill monthly',
        shipping_desc: ' every month',
        billing_desc: '/month',
        billing_recurrence: 'monthly',
        billing_interval_unit: 'months',
        billing_interval_length: 1,
        services_per_billing_cycle: 1,
        monthly_cost: lambda {|amount| amount },
        service_cost: lambda {|amount| amount }
      },
      monthly_bill_every_2_months: {
        name: 'Ship monthly, bill every 2 months',
        shipping_desc: ' every month',
        billing_desc: '/2 months',
        billing_recurrence: 'every 2 months',
        billing_interval_unit: 'months',
        billing_interval_length: 2,
        services_per_billing_cycle: 2,
        monthly_cost: lambda {|amount| amount/2 },
        service_cost: lambda {|amount| amount/2 }
      },
      bimonthly_bill_every_2_months: {
        name: 'Ship every other month, bill every other month',
        shipping_desc: ' every 2 months',
        billing_desc: '/2 months',
        billing_recurrence: 'every 2 months',
        billing_interval_unit: 'months',
        billing_interval_length: 2,
        services_per_billing_cycle: 1,
        monthly_cost: lambda {|amount| amount/2 },
        service_cost: lambda {|amount| amount }
      },
      bimonthly_bill_annually: {
        name: 'Ship every other month, bill annually',
        shipping_desc: ' every 2 months',
        billing_desc: '/year',
        billing_recurrence: 'every 2 months',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 6,
        monthly_cost: lambda {|amount| amount/12 },
        service_cost: lambda {|amount| amount/6 }
      },
      monthly_bill_quarterly: {
        name: 'Ship monthly, bill quarterly',
        shipping_desc: ' every month',
        billing_desc: ' every 3 months',
        billing_recurrence: 'quarterly',
        billing_interval_unit: 'months',
        billing_interval_length: 3,
        services_per_billing_cycle: 3,
        monthly_cost: lambda {|amount| amount / 3 },
        service_cost: lambda {|amount| amount / 3 }
      },
      monthly_bill_semi_annually: {
        name: 'Ship monthly, bill semi annually',
        shipping_desc: ' every month',
        billing_desc: ' every 6 months',
        billing_recurrence: 'semi annually',
        billing_interval_unit: 'months',
        billing_interval_length: 6,
        services_per_billing_cycle: 6,
        monthly_cost: lambda {|amount| amount / 6 },
        service_cost: lambda {|amount| amount / 6 }
      },
      monthly_bill_annually: {
        name: 'Ship monthly, bill annually',
        shipping_desc: ' every month',
        billing_desc: '/year',
        billing_recurrence: 'yearly',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 12,
        monthly_cost: lambda {|amount| amount / 12 },
        service_cost: lambda {|amount| amount / 12 }
      },
      quarterly: {
        name: 'Ship/bill quarterly',
        shipping_desc: ' quarterly',
        billing_desc: ' every 3 months',
        billing_recurrence: 'quarterly',
        billing_interval_unit: 'months',
        billing_interval_length: 3,
        services_per_billing_cycle: 1,
        monthly_cost: lambda {|amount| amount / 3 },
        service_cost: lambda {|amount| amount }
      },
      quarterly_biannually: {
        name: 'Ship quarterly, bill every 2 years',
        shipping_desc: ' quarterly',
        billing_desc: ' every 2 years',
        billing_recurrence: 'every 2 years',
        billing_interval_unit: 'months',
        billing_interval_length: 24,
        services_per_billing_cycle: 8,
        monthly_cost: lambda {|amount| amount / 24 },
        service_cost: lambda {|amount| amount / 8}
      },
      quarterly_annually: {
        name: 'Ship quarterly, bill annually',
        shipping_desc: ' quarterly',
        billing_desc: ' annually',
        billing_recurrence: 'annually',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 4,
        monthly_cost: lambda {|amount| amount / 12 },
        service_cost: lambda {|amount| amount / 4 }
      },
      semiannually_annually: {
        name: 'Ship semi-annually, bill annually',
        shipping_desc: ' semi-annually',
        billing_desc: '/year',
        billing_recurrence: 'annually',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 2,
        monthly_cost: lambda {|amount| amount/12 },
        service_cost: lambda {|amount| amount/2 }
      },
      annually: {
        name: 'Ship/bill annually',
        shipping_desc: ' annually',
        billing_desc: '/year',
        billing_recurrence: 'annually',
        billing_interval_unit: 'months',
        billing_interval_length: 12,
        services_per_billing_cycle: 1,
        monthly_cost: lambda {|amount| amount/12 },
        service_cost: lambda {|amount| amount }
      }
    }

  def self.data
    RECURRENCES
  end

  def self.get(type)
    self.data.fetch(type.to_sym)
  end

  def self.recurrence_types
    types = {}
    self.data.each do |key, value|
      types[value[:name]] = key
    end
    types
  end
end
