define(['jquery', 'lib/recurly'], function ($) {
  if (typeof _recurly_config !== 'undefined') {
    Recurly.config(_recurly_config);
  }

  if (typeof _recurly_billing_info_update_form !== 'undefined') {
    Recurly.buildBillingInfoUpdateForm(_recurly_billing_info_update_form);
  }

  /**
   * Style changes to the form after it loaded.
   */
  var amendFormInterval = null;
  function amendForm() {
    if ($('form.recurly.update_billing_info').length === 0) {
      return;
    }
    clearInterval(amendFormInterval);
    amendFormInterval = null;
    $('form.recurly.update_billing_info .billing_info > .title')
      .html('Name');
    $('form.recurly.update_billing_info .billing_info .card_number .placeholder')
      .html('Number');
    $('form.recurly.update_billing_info .billing_info .address .country')
      .prepend('<div class="placeholder">Country</div>');
    $('form.recurly.update_billing_info .billing_info .zip .placeholder')
      .html('ZIP Code');
    $('form.recurly.update_billing_info .footer button')
      .addClass('btn secondary');
    $('form.recurly.update_billing_info .credit_card')
      .prepend('<div class="title">Credit Card</div>');
  }

  $(function () {
    amendFormInterval = setInterval(amendForm, 100);
  });

});
