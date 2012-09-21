class Ability
  include CanCan::Ability

  # :create => new, create actions
  # :read => index, show actions
  # :update => edit, update actions
  # :destroy => destroy action
  # :manage => [:create, :read, :update, :destroy]
  #
  # Note: for this permissions to apply you need to put authorize_resouce on the controller
  # Note: if you also put load_resource the resource will be loaded on all 7 CRUD actions for free!

  def initialize(user)
    if user && user.is_active?
      # Abilities for authenticated users
      can :manage, Subscription, user_id: user.id
      can :manage, Resque
      can [:edit, :update, :edit_password, :update_password], :setting
      can :manage, ShippingInfo, user_id: user.id
      can [:inactivate], :registration
      can [:destroy], :session
      can [:my_preferences, :create, :destroy], UserPreference, user_id: user.id
      can :index, Coupon
      can [:destroy, :index], Authentication, user_id: user.id
      can [:submit, :confirmation, :submit_shipping_info, :coupon_valid], :plan_configurator
      can :create, Friend
      can :manage, :billing_info
    else
      # Abilities for non authenticated users
      can [:new, :create, :form], :session
      can [:new, :create, :form, :new_with_coupon, :create_with_coupon], :registration
    end

    # Everyone has these abilities
    can [:read, :highlights], Category
    can :read, CategoryGroup
    can [:read, :highlights], Tag
    can [:preview, :filtered, :index, :home, :show, :summary], Plan
    can :index, UserPreference
    can :new, Friend
    can [:zipcode_confirmation, :zipcode_confirmation_submit, :checkout, :display_totals], :plan_configurator
    can [:create, :failure], Authentication

    can :show, :search

    can [:home, :sitemap, :deals, :featured, :coming_soon, :how_it_works, :terms_of_service, :privacy_policy, :about, :why_monthlys, :what_is_monthlys, :affiliate_program,:guarantee, :quality, :jobs, :contact, :contact_submit, :record, :beer], :page

    can [:update_location, :enter_zip, :persistent_dismiss], :setting
    can [:create, :thank_you, :terms, :show], Merchant
    can :create, NewsletterSubscriber

    # Marketing module
    can :read, Marketing::Newsletter
    can :create, Marketing::UserAttachment
  end
end
