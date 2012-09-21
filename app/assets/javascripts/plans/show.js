/*jslint indent: 2*/
/*global define*/
define([
  'jquery', 'app/google_map', 'app/image_placeholder', 'app/widgets/image_slider',
  'app/newsletter_form', 'app/plans/tabs', 'app/plans/configurator',
  'plans/video_reviews', 'app/plans/subscription_archive', 'app/sidebar',
  'app/modalvideo', 'lib/jquery.infieldlabel', 'lib/jquery.stylableselect',
  'lib/jquery.colorbox', '//assets.pinterest.com/js/pinit.js'
], function ($, maps, placeholder, ImageSlider, newsletterForm, planTabs,
     planConfigurator, videoReviews, SubscriptionArchive) {
  'use strict';

  function loadMerchantMap(planMerchant) {
    if (planMerchant.location.show === true && planMerchant.location.lat && planMerchant.location.lng) {
      maps(planMerchant.location.lat, planMerchant.location.lng, "map-canvas", planMerchant.business_name);
    }
  }

  function loadImagePlaceholders() {
    placeholder
      .replace('div.main-img-wrapper img', '/assets/default/plan-image.png')
      .replace('a.merchant-image img', '/assets/default/merchant-image.png')
      .replace('div.merchant-info img', '/assets/default/merchant-logo.png');
  }

  function loadNewsletterForm() {
    var form;

    form = $('#newsletter_form').eq(0);
    form.find('label').inFieldLabels();
    newsletterForm.init({ form: form });
  }

  function loadConfiguratorForm() {
    $('.configuration select').stylableSelect();
  }

  function loadGiftingModal() {
    $('#show-gifting-hiw').colorbox({
      href: '#gifting-hiw',
      inline: true,
      width: 700,
      fixed: true
    });
  }

  function loadVideo() {
    var video = $('iframe.youtube:first').eq(0)
      , play;

    if (video) {
      play = video.nextAll('img, .play');
      video.remove();

      play.click(function (e) {
        e.preventDefault();
        play.hide();
        video.insertBefore(play.eq(0)).show();
      });

      if (video.data('autoplay') === true) {
        play.click();
      }
    }
  }

  function loadSubscriptionArchive(planId) {
    var elements, subscriptionArchive;

    elements = $('#plan-subscription-archive').find('a');
    subscriptionArchive = new SubscriptionArchive(planId);
    subscriptionArchive.showOn('click', elements);
  }


  return {
    init: function (context) {
      var planImages;
      loadVideo();
      loadGiftingModal();
      loadNewsletterForm();
      if (!$.browser.msie) {
        loadConfiguratorForm();
      }
      loadImagePlaceholders();
      loadMerchantMap(context.planMerchant);

      planImages = new ImageSlider($('.image-nav'))
      planImages.init();

      planTabs.init();

      planConfigurator.init(context.configuratorOptions);

      // Video reviews
      videoReviews.init({ selector: '.video-review-link' });

      // Plan subscription archive
      loadSubscriptionArchive(context.planId);
    }
  };
});
