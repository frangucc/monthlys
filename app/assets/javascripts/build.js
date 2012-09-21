({
  include: [
    'requireLib',
    // Layouts
    'layouts/application',
    // View-specific modules
    'business/scripts',
    'categories/index',
    'categories/show',
    'category_groups/show',
    'friends/new',
    'marketing/user_attachments/new',
    'merchant_storefront/pages/contact',
    'merchant_storefront/pages/how_it_works',
    'merchant_storefront/plans/home',
    'pages/coming_soon',
    'pages/contact',
    'pages/deals',
    'pages/home',
    'pages/how_it_works',
    'pages/featured',
    'pages/beer',
    'plans/filtered',
    'plans/index',
    'plans/show',
    'plan_configurators/checkout',
    'registrations/new',
    'registrations/new_with_coupon',
    'sessions/new',
    'settings/edit',
    'shipping_infos/form',
    'subscriptions/edit',
    'subscriptions/new',
    'subscriptions/index',
    'subscriptions/show',
    'superhubs/show',
    'tags/show',
    'user_preferences/index',
    'views/billing_infos/edit',
    'views/billing_infos/new'
  ],
  baseUrl: '.',
  paths: { requireLib: 'require' },
  out: '../../../public/assets/all.js'
})