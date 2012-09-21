define([
  'jquery',
  'plan_configurators/terms_modal',
  'app/recurly_subscriptions_form',
  'plan_configurators/submission_manager',
  'debug',
  'plan_configurators/refresh_totals',
  'app/in_field_label',
  'app/messages',
  'plan_configurators/shipping',
  'plan_configurators/gifting',
  'plan_configurators/email_preview',
  'plan_configurators/guest_checkout'
], function ($, termsModal, recurlySubscriptionsForm, SubmissionManager, debug, totals) {

  var subscriptionForm = $('#new_subscription'),
      sm,
      smStates = [];

  function updateShippingInfoId(id) {
    $('#subscription_shipping_info_id').val(id);
    totals.refresh();
    return id;
  }

  function submitAddressesForm(sm) {
    var addressesForm = $('#addresses > form'),
        couponCode = $('#subscription_coupon_code').val(),
        requestParams = addressesForm.serialize();

    if (couponCode !== '') {
      requestParams = [requestParams, '&coupon[coupon_code]=', couponCode].join('');
    }

    // Show loader
    $('#addresses .loader').show();
    $.post(
      addressesForm.attr('action'),
      requestParams,
      function (data) {
        // Hide loader
        $('#addresses .loader').hide();
        var new_shipping_info_id;

        // Callback called after shipping request finished.
        if (data.status === 'error') {
          addressesForm.displayResourceErrors({
            errors: data.errors
          });
        } else if (data.status === 'success') {
          addressesForm.find('.error-message').remove(); // TODO: move this to a JS module

          new_shipping_info_id = $('#shipping_info_id');
          if (new_shipping_info_id.val() === '') {
            new_shipping_info_id.val(data.shipping_info_id);
          }

          if (data.coupon_id !== null) {
            $('#subscription_coupon_id').val(data.coupon_id);
          }

          updateShippingInfoId(data.shipping_info_id);
          debug.log('Shipping info created/updated.');
          sm.done('shipping');
        }
      }
    );
  }
  debug.log('Show forms:', show_form);
  function submitRecurlyForm(sm) {
    $('#recurly-subscribe > form').submit();
  }

  function submitSubscription() {
    var isGift = $('#gifting_is_gift').is(':checked')
      , paramsMap = { is_gift: '0' };

    if (isGift) {
      paramsMap = {
        is_gift: '1',
        giftee_name: $('#gifting_giftee_name').val(),
        giftee_email: $('#gifting_giftee_email').val(),
        gift_description: $('#gifting_gift_description').val(),
        notify_giftee_on_email: $('#gifting_notify_giftee_on_email').is(':checked') ? '1' : '0',
        notify_giftee_on_shipment: $('#gifting_notify_giftee_on_shipment').is(':checked') ? '1' : '0'
      }
    }

    $.each(paramsMap, function (name, value) {
      subscriptionForm.append('<input type="hidden" name="subscription[' + name + ']" value="' + value + '" />');
    });

    // Callback called after billing and/or shipping callbacks
    // finished (if needed).
    debug.log('Submiting subscription...');
    debug.log('  PR id:', $('#subscription_plan_recurrence_id').val());
    debug.log('  Shipping info id:', $('#subscription_shipping_info_id').val());

    subscriptionForm.submit();
  }

  if (show_form.billing) {
    smStates.push('billing');

    recurlySubscriptionsForm.initialize(function () {
      // Callback called after billing request successfully finished.
      debug.log('Billing info created/updated.');
      sm.done('billing', true);
      $('#billing').remove();
    });
  }

  if (show_form.shipping || show_form.personal) {
    smStates.push('shipping');
  }

  debug.log('Initializing SubsmissionManager with states: ', smStates);
  sm = new SubmissionManager(smStates, submitSubscription);

  subscriptionForm.find('#submit-checkout').click(function (event) {
    event.preventDefault();

    // Temp disable terms and conditions.
    //if (!termsModal.isTermsAccepted()) {
    //  return;
    //}

    if(!show_form.shipping && !show_form.billing && !show_form.personal) {
      submitSubscription();
    }
    else {
      sm.reset();

      if ((show_form.personal) ||
          (show_form.shipping && !show_form.shipping_select) ||
          (show_form.shipping_select && $('#add-new-shipping-option').is(':checked'))) {
        // New shiping info
        submitAddressesForm(sm);
      }
      else if (show_form.shipping_select) {
        // Existing shipping info selected
        sm.done('shipping');
      }

      if (show_form.billing) {
        submitRecurlyForm(sm);
      }
    }
  });


  /*
   * Modify billing form to match the design.
   * As we dont own the markup for this form we have
   * to wait until it comes from recurly and them
   * change it.
   */
  function waitForBillingForm() {
    var el = $('#billing .billing_info');
    if (el.length === 0) {
      setTimeout(waitForBillingForm, 200);
    }
    else {
      rearrangeBillingForm();
    }
  }

  function rearrangeBillingForm() {
    var wrapper = $('#billing .billing_info'),
        credit_card = wrapper.find('.credit_card');

    $('#billing div.title').remove();

    // labels
    $('<div class="title name">Name on card *</div>').appendTo(credit_card);
    $('<div class="title number">Card number *</div>').appendTo(credit_card);
    $('<div class="title cvv">Security Code *</div>').appendTo(credit_card);
    $('<div class="title expires">Expiration Date *</div>').appendTo(credit_card);

    // helpers
    $('<span class="helper cvv">aka CVC or CVV. Last 3 digits on the back of your credit card. (Amex: 4 digits on front).</span>').appendTo(credit_card);
    $('<span class="helper expires">The date your credit card expires. Find this on the front of your credit card.</span>').appendTo(credit_card);

    // in field labels
    $('#billing label').inFieldLabels();
  }

  waitForBillingForm();
  $('#addresses label:not(.title)')
    .add('#addresses div.field.zipcode label')
    .add('#addresses div.field.city label').inFieldLabels();

  /*
   * Refreshing totals when zipcode_str loses focus
   */
  $('#personal_info_zipcode_str, #shipping_info_zipcode_str').blur(function (event) {
    debug.log('Triggered refresh by zipcode change', $(this).val());
    totals.refresh({ forceZipcode: $(this).val() });
  });

});
