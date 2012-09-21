require 'minitest/autorun'

# We shall brave through this test cases
class TestRapi < MiniTest::Unit::TestCase
  def get_account(user)
    ::Recurly::Account.find(user.recurly_code)
  end

  def get_plan(plan_recurrence)
    ::Recurly::Plan.find(plan_recurrence.recurly_plan_code)
  end

  def get_addon(option_recurly_code)
    rp = get_plan(option_recurly_code.plan_recurrence)
    rp.add_ons.find(option_recurly_code.recurly_code)
  end

  def get_recurly_addon(plan_code, addon_code)
    ::Recurly::Plan.find(plan_code).add_ons.find(addon_code)
  end

  def get_recurly_coupon(recurly_code)
    ::Recurly::Coupon.find(recurly_code)
  end

  def assert_invoice_attrs(inv, rinv)
    assert_equal(inv.invoice_number, rinv.invoice_number)
    assert_equal(inv.uuid, rinv.uuid)
    assert_equal(inv.status, rinv.state)
    assert_equal(inv.total_in_usd,
                 Monthly::Rapi::Utils.convert_to_usd(rinv.total_in_cents))
    assert_equal(inv.subtotal_in_usd,
                 Monthly::Rapi::Utils.convert_to_usd(rinv.subtotal_in_cents))
    refute_nil(inv.user)
    assert_equal(inv.user,
                 Monthly::Rapi::Accounts::Helpers::user_for_recurly_account(rinv.account))
  end

  def assert_invoice_line_attrs(line, radj)
    assert_equal(line.uuid, radj['uuid'])
    assert_equal(line.description, radj['description'])
    assert_equal(line.origin, radj['origin'])
    assert_equal(line.quantity, radj['quantity'])
    assert_equal(line.start_date, radj['start_date'])
    assert_equal(line.end_date, radj['end_date'])
    assert_equal(line.unit_amount_in_usd,
                 Monthly::Rapi::Utils.convert_to_usd(radj['unit_amount_in_cents']))
    assert_equal(line.discount_in_usd,
                 Monthly::Rapi::Utils.convert_to_usd(radj['discount_in_cents']))
    assert_equal(line.recurly_created_at, radj['created_at'])
    if line.origin == 'plan'
      pr = PlanRecurrence.find_by_recurly_plan_code(radj['accounting_code'])
      refute_nil(pr)
      s = Subscription.find_by_plan_recurrence_id(pr.id)
      refute_nil(s)
      assert_equal(line.subscription_id, s.id)
    else
      assert_nil(line.subscription_id)
    end
  end

  def assert_invoice_lines(inv, rinv)
    assert_equal(inv.invoice_lines.count, rinv.line_items.length)

    adjustments_by_uuid = Hash[rinv.line_items.map { |r| [ r['uuid'], r ] }]
    inv.invoice_lines.find_each do |line|
      assert_includes(adjustments_by_uuid, line.uuid)
      assert_invoice_line_attrs(line, adjustments_by_uuid[line.uuid.to_s])
    end
  end

  def find_and_assert_invoice(invoice_number)
    inv = Monthly::Rapi::Invoices.fetch_and_update(invoice_number)
    rinv = ::Recurly::Invoice.find(invoice_number)
    assert_invoice_attrs(inv, rinv)
    assert_invoice_lines(inv, rinv)
  end

  # Tests

  def test_coupons
    # Test Coupons.sync() create
    coupon = Coupon.new(coupon_code: 'test',
                        name: 'My test coupon',
                        discount_type: 'percent',
                        discount_percent: 50)
    puts "Coupon: '#{coupon.name}' code: '#{coupon.coupon_code}'"

    puts "Testing Rapi::Coupons.sync(coupons) create"
    coupon = Monthly::Rapi::Coupons.sync(coupon)
    rcoupon = get_recurly_coupon(coupon.recurly_code)
    assert_equal(coupon.recurly_code, rcoupon.coupon_code)

    puts "  Recurly code #{coupon.recurly_code}"
    puts "  - https://billably.recurly.com/coupons/"

    # Test Coupons.sync() update

    puts "Testing Rapi::Coupons.sync(coupons) update and plan coupons"

    # Plans
    m = Merchant.new(business_name: 'test merchant', shipping_type: 'flat_rate', shipping_rate: 5)
    m.save(validate: false)
    p1 = Plan.new(name: 'test plan 1', plan_type: 'news')
    p1.save(validate: false)
    p2 = Plan.new(name: 'test plan 2', plan_type: 'news')
    p2.save(validate: false)
    # Recurrences
    pr11 = p1.plan_recurrences.new(recurrence_type: 'monthly', amount: 1000)
    pr11.save(validate: false)
    pr12 = p1.plan_recurrences.new(recurrence_type: 'weekly', amount: 4000)
    pr12.save(validate: false)
    pr21 = p2.plan_recurrences.new(recurrence_type: 'weekly', amount: 300)
    pr21.save(validate: false)

    p1 = Monthly::Rapi::Plans.sync(p1)
    p2 = Monthly::Rapi::Plans.sync(p2)

    [p1, p2].each do |p|
      p.plan_recurrences.each do |pr|
        puts "  Recurly plan: #{pr.recurly_plan_code}"
        puts "  - https://billably.recurly.com/plans/#{pr.recurly_plan_code}"
      end
    end

    coupon.discount_in_usd = 101.50
    coupon.discount_type = "dollars"
    coupon.applies_to_all_plans = false
    coupon.plans = [p1, p2]
    coupon.save(validate: false)

    old_rcode = coupon.recurly_code
    coupon = Monthly::Rapi::Coupons.sync(coupon)
    rcoupon = get_recurly_coupon(coupon.recurly_code)
    assert_equal(coupon.recurly_code, rcoupon.coupon_code)
    assert_equal(get_recurly_coupon(old_rcode).state, 'inactive')

    puts "  Recurly code #{coupon.recurly_code}"
    puts "  - https://billably.recurly.com/coupons/"
  end

  def test_rapi_modules
    # Rapi::Accounts

    code = Monthly::Rapi::Utils.ucode('')
    user = User.new(
      email: "rapitest#{code}@monthlys.com",
      full_name: "Rapi Test #{code}#",
    )
    user.save(validate: false)

    puts "User: #{user.email} id:#{user.id}"

    # Test Accounts.sync() create
    puts "Testing Rapi::Acounts.sync(user) create"
    Monthly::Rapi::Accounts.sync(user)
    raccount = get_account(user)
    assert_equal(user.recurly_code.to_s, raccount.account_code)

    puts "  Recurly code #{user.recurly_code}"
    puts "  - https://billably.recurly.com/accounts/#{user.recurly_code}"

    # Test Accounts.sync() update
    puts "Testing Rapi::Acounts.sync(user) update"
    user.full_name += " (#{user.recurly_code})"
    user.save(validate:false)
    Monthly::Rapi::Accounts.sync(user)
    raccount = get_account(user)
    assert_equal(user.email, raccount.email)

    puts "Testing Rapi::Acounts.recurly_account(user)"
    acc = Monthly::Rapi::Accounts.recurly_account(user)
    assert_equal(get_account(user).account_code, acc.account_code)

    puts "Testing Rapi::Acounts.close(user)"
    Monthly::Rapi::Accounts.close(user)
    raccount = get_account(user)
    assert_equal(raccount.state, 'closed')
    assert_equal(user.is_active, false)

    puts "Testing Rapi::Acounts.reopen(user)"
    Monthly::Rapi::Accounts.reopen(user)
    raccount = get_account(user)
    assert_equal(raccount.state, 'active')
    assert_equal(user.is_active, true)

    puts "Testing Rapi::Acounts.billing_info(user)"
    binfo = Monthly::Rapi::Accounts.billing_info(user)
    assert_nil(binfo)


    # Rapi::Plans

    # Plan
    m = Merchant.new(business_name: 'test merchant', shipping_type: 'flat_rate',
                     shipping_rate: 5, taxation_policy: 'no_taxes')
    m.save(validate: false)
    p = Plan.new(name: 'test plan', plan_type: 'news', merchant: m)
    p.save(validate: false)
    # Recurrences
    pr1 = p.plan_recurrences.new(recurrence_type: 'monthly', amount: 1000)
    pr1.save(validate: false)
    pr2 = p.plan_recurrences.new(recurrence_type: 'weekly', amount: 4000)
    pr2.save(validate: false)
    # Addons
    g_add = p.option_groups.new(description: 'Addons group', option_type: 'recurring')
    g_add.save(validate: false)
    add1 = g_add.options.new(title: 'Special one', amount: 100)
    add1.save(validate: false)
    add2 = g_add.options.new(title: 'Special five', amount: 500)
    add2.save(validate: false)
    # No-charge options
    g_nco = p.option_groups.new(description: 'No charge group', option_type: 'nocharge')
    g_nco.save(validate: false)
    nco = g_nco.options.new(title: 'Color blue')
    nco.save(validate: false)
    # One time options
    g_oto = p.option_groups.new(description: 'One time group', option_type: 'onetime')
    g_oto.save(validate: false)
    oto1 = g_oto.options.new(title: 'Setup fee', amount: 200)
    oto1.save(validate: false)
    oto2 = g_oto.options.new(title: 'One time charge', amount: 300)
    oto2.save(validate: false)

    puts 'Testing Rapi::Plans.sync(plan) create and addons'
    Monthly::Rapi::Plans.sync(p)
    p.plan_recurrences.each do |pr|
      rplan = get_plan(pr)
      puts "  Recurly plan: #{rplan.plan_code}"
      puts "  - https://billably.recurly.com/plans/#{rplan.plan_code}"
      assert_equal(pr.recurly_plan_code, rplan.plan_code)
      # Addons
      orcs = PlanRecurrence.find(pr.id).option_recurly_codes
      orcs.each do |orc|
        raddon = get_addon(orc)
        puts "    Addon #{raddon.add_on_code}"
        assert_equal(raddon.add_on_code, orc.recurly_code) # I know...
      end
      # Shipping addon
      puts "    Addon shipping"
      raddon = get_recurly_addon(pr.recurly_plan_code, 'shipping')
      assert_equal(raddon.add_on_code, 'shipping') # We know...
    end

    puts 'Testing Rapi::Plans.sync(plan) edit (and recurly plan names)'
    p.name = "Rapi #{p.name}"
    p.save(validate: false)
    Monthly::Rapi::Plans.sync(p)
    p.plan_recurrences.each do |pr|
      rplan = get_plan(pr)
      puts "  Recurly plan: #{rplan.plan_code}"
      recurrence = Recurrence.get(pr.recurrence_type)
      assert_equal("#{p.name} (#{recurrence[:name]})", rplan.name)
    end


    # Rapi::Subscriptions

    # Create fake billing info
    raccount = get_account(user)
    raccount.billing_info = {
      first_name: 'Fake',
      last_name: 'Data',
      number: '4111-1111-1111-1111',
      verification_value: '123',
      month: 11,
      year: 2015
    }
    raccount.billing_info.save

    coupon = Coupon.new(coupon_code: 'testcoupon',
                        name: 'test coupon',
                        discount_type: 'percent',
                        discount_percent: 40)
    coupon.save(validate: false)
    coupon = Monthly::Rapi::Coupons.sync(coupon)

    puts 'Testing Rapi::Subscriptions.create()'
    opts = [add2, nco, oto1]
    s = Monthly::Rapi::Subscriptions.create(user: user,
                                            plan_recurrence: pr2,
                                            options: opts,
                                            coupon: coupon)
    puts "  Recurly subscription: #{s.recurly_code}"
    puts "  - https://billably.recurly.com/subscriptions/#{s.recurly_code}"
    assert_equal(s.subscription_options.length, opts.length)

    # Rapi::Invoices

    puts 'Testing Rapi::Invoices.fetch_and_update()'
    find_and_assert_invoice(raccount.invoices.first.invoice_number)
  end
end
