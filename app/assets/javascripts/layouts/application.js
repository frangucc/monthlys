define([
  'app/widgets/pulldown', 'app/widgets/plan_preview', 'app/city_dropdown',
  'app/sitewide_search', 'app/header_promo', 'app/ajax_signup',
  'app/link_methods', 'lib/modernizr'
], function (pulldown, planPreviewManager) {

  function initPulldown(options) {
    pulldown.init({ userSignedIn: options.userSignedIn,
                    autoOpen: options.autoOpen });
  }

  return {
    init: function (context) {
      initPulldown({ autoOpen: context.autoOpen,
                     userSignedIn: context.userSignedIn });

      planPreviewManager.init();
    }
  };
});
