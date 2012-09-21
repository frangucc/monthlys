define(['jquery', 'app/routes', 'debug'], function ($, Routes, debug) {
  /**
   * Refreshes confirmation totals
   * It should only refresh it when there's at least 1 shipping info selected for shippable plans.
   * For non-shippable plans it should always refresh.
   * This is used to update the price when changing plan_recurrence/options/shipping_info
   */
  function refreshConfirmationTotals(options) {
    var paramsStr = $('#new_subscription').serialize(),
        path = Routes.confirmation,
        zipcode = options && options.forceZipcode;

    if (zipcode) { // Sending the zipcode given in the options
      paramsStr += '&zipcode_str=' + zipcode;
    }

    debug.log('Refreshing totals...');
    debug.log('   Path', path);
    debug.log('   Params', decodeURIComponent(paramsStr));
    debug.log('   Zipcode', zipcode);

    $.get([path, paramsStr].join('?'), function (data) {
      hidePromoCode();
      debug.log('Refreshing totals done.');
    });
  }

  /**
   * Hides the promo code form and applies the
   * handlers to open it when clicked.
   */
  function hidePromoCode() {
    var form;
    if (!!window.promoCodeOpen) {
      return;
    }
    form = $('p.coupon-field input, p.coupon-field .btn');
    if (form.val() === '') {
      form.hide();
    }
    else {
      window.promoCodeOpen = true;
      refreshConfirmationTotals();
      form.show();
    }
    $('p.coupon-field label').click(function () {
      form.show('fast');
      window.promoCodeOpen = true;
    });
  }

  hidePromoCode();
  $('#redeem-btn').click(function (event) {
    var couponCode = $('#coupon_coupon_code').val()
      , couponForm = $('#coupon_form')
      , couponId = $('#subscription_coupon_id')
      , messagesContainer = couponForm.find('.messages');

    event.preventDefault();

    // Clearing messages
    messagesContainer.empty();
    couponForm.find('.error-message').remove();

    $.getJSON([Routes.couponValid, $.param({ coupon: { coupon_code: couponCode } })].join('?'), function (data) {
      if (data.status === 'success') {
        couponId.val(data.coupon_id);
        messagesContainer.displayMessage('success', data.message);
        $('#redeem-btn').addClass('valid').val('Valid');
      }
      else {
        couponId.val('');
        couponForm.find('.messages').displayMessage('error', data.errors);
      }
      refreshConfirmationTotals();
    });
  });

  return {
    refresh: refreshConfirmationTotals
  };
});
