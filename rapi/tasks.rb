namespace :rapi do
  desc 'Test Rapi module'
  task :test => :environment do
    require_relative 'tests.rb'
  end

  desc 'Create new invoices from recurly'
  task :create_invoices => :environment do
    Monthly::Rapi::Invoices.create_new
  end

  desc "Sync entities that require syncing"
  task :sync => %w(sync:plans sync:accounts sync:coupons)

  namespace :sync do
    desc "Sync any plans that need to be synced"
    task :plans, [:min, :max] => :environment do |task, args|
      args.with_defaults(min: "1", max: Plan.maximum(:id).to_s)

      Plan.where(id: args[:min]..args[:max]).find_each do |plan|
        puts "Synchronizing plan '#{plan.name} (ID: #{plan.id}) with Recurly"
        Monthly::Rapi::Plans.sync(plan)
      end
    end

    desc "Sync any coupons that need to be synced"
    task :coupons, [:min, :max] => :environment do |task, args|
      args.with_defaults(min: "1", max: Coupon.maximum(:id).to_s)

      Coupon.where(id: args[:min]..args[:max]).find_each do |coupon|
        if coupon.expired?
          puts "#{coupon.id} expired. Not synchronizing it."
        else
          puts "Synchronizing coupon '#{coupon.coupon_code} (ID: #{coupon.id}) with Recurly"
          Monthly::Rapi::Coupons.sync(coupon)
        end
      end
    end

    desc "Sync any accounts that need to be synced"
    task :accounts, [:min, :max] => :environment do |task, args|
      args.with_defaults(min: "1", max: User.maximum(:id).to_s)

      User.where(id: args[:min]..args[:max]).find_each do |user|
        puts "Synchronizing account #{user.email} (ID: #{user.id}) with Recurly"
        Monthly::Rapi::Accounts.sync(user)
      end
    end

    desc "Sync monthlys_accounts.yml accounts"
    task :monthlys_accounts => :environment do |task, args|
      User.where(email: YAML.load_file('config/monthlys_accounts.yml')).find_each do |user|
        puts "Synchronizing account #{user.email} (ID: #{user.id}) with Recurly"
        Monthly::Rapi::Accounts.sync(user)
      end
    end
  end

  namespace :clear do
    desc "De-sync Recurly plans with our DB plans"
    task :plans, [:min, :max] => :environment do |task, args|
      abort 'This cannot be run in production' if Rails.env.production?
      puts 'This will un-link the Recurly plans that are currently on our DB'

      args.with_defaults(min: "1", max: Plan.maximum(:id).to_s)

      confirm do
        PlanRecurrence.where(plan_id: args[:min]..args[:max]).find_each do |plan_recurrence|
          plan_recurrence.update_attribute(:recurly_plan_code, '')
          plan_recurrence.option_recurly_codes.destroy_all
        end
      end
    end

    desc "De-sync Recurly coupons with our DB coupons."
    task :coupons, [:min, :max] => :environment do |task, args|
      abort 'This cannot be run in production' if Rails.env.production?
      puts 'This will un-link the Recurly coupons that are currently on our DB'

      args.with_defaults(min: "1", max: Coupon.maximum(:id).to_s)

      confirm do
        Coupon.where(id: args[:min]..args[:max]).update_all(recurly_code: '')
      end
    end

    desc "De-sync Recurly accounts with our DB users."
    task :accounts, [:min, :max] => :environment do |task, args|
      abort 'This cannot be run in production' if Rails.env.production?
      puts 'This will un-link the Recurly accounts that are currently on our DB'

      args.with_defaults(min: "1", max: User.maximum(:id).to_s)

      confirm do
        User.where(id: args[:min]..args[:max]).update_all(recurly_code: '')
      end
    end
  end

  # Helper method to confirm user actions.
  #
  # If the user answers y, Y, yes, or YES then yields control to the passed
  # block, otherwise aborts.
  def confirm(question = "Are you sure? (y/n)")
    puts question
    answer = $stdin.gets.chomp
    if answer =~ /y(es)?/i
      yield
    else
      abort "Can't continue if you don't say yes :("
    end
  end
end
