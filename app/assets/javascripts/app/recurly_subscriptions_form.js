define(['jquery', 'lib/recurly'], function ($) {

  var updateBillingInfoSettings = null;

  if (typeof _recurly_build_subscription_form !== 'undefined') {
    updateBillingInfoSettings = _recurly_build_subscription_form;
  }

  /**
   * Will make a call to recurly.js to build the billing info update form
   */
  function loadRecurlyForm(callback) {
    if (updateBillingInfoSettings !== null) {
      updateBillingInfoSettings.afterUpdate = callback;
      Recurly.buildBillingInfoUpdateForm(updateBillingInfoSettings);
    }
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
      .html('Credit Card');
    $('form.recurly.update_billing_info .billing_info .card_number .placeholder')
      .html('Number');
    $('form.recurly.update_billing_info .footer button').remove();
  }

  return {
    initialize: function (callback) {
      if (typeof _recurly_config !== 'undefined') {
        Recurly.config(_recurly_config);
      }

      loadRecurlyForm(callback);
      amendFormInterval = setInterval(amendForm, 100);
    }
  };

});
