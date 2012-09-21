define(['jquery'], function ($) {

  var CheckoutFormHandler = function (settings) {
    this.dummyForm = settings.dummyForm;
    this.subscriptionForm = settings.subscriptionForm;
    this.routes = settings.routes;
  };

  CheckoutFormHandler.prototype.getOptionsId = function() {
    var optionsId = []
      , optionsSelect = this.dummyForm.find('.option-group select');

    optionsSelect.each(function (index, select) {
      var value = $(select).val();

      if (typeof value === 'number' || typeof value === 'string') {
        optionsId.push(value);
      } else if (value !== null) { // It's a list of values
        $.merge(optionsId, value);
      }
    });

    return optionsId;
  };

  CheckoutFormHandler.prototype.getSubscriptionParams = function () {
    var subscriptionParams = {}
      , shippingInfoSelect = this.dummyForm.find('#shipping_info_id')
      , planRecurrenceSelect = this.dummyForm.find('#plan_recurrence_id');

    subscriptionParams.options_id = this.getOptionsId();
    subscriptionParams.plan_recurrence_id = planRecurrenceSelect.val();
    if (shippingInfoSelect.length !== 0) {
      subscriptionParams.shipping_info_id = shippingInfoSelect.val();
    }

    return subscriptionParams;
  };

  CheckoutFormHandler.prototype.refreshTotals = function () {
    var params = { subscription: this.getSubscriptionParams() };

    $.get(this.routes.totals, params, function (data) {

      $('#confirmation').empty();
      $('#checkoutTotals').tmpl(data).appendTo('#confirmation');

      $(data.refresh_options).each(function (index, option) {
        $('.stylableselect option[value="' + option.id + '"]').html(option.billing_desc);
        $('.stylableselect div.listitem[data-value="' + option.id + '"] .priceDesc').html(option.billing_desc);
      });
    });
  };

  CheckoutFormHandler.prototype.submitSubscription = function (callback) {
    var params = { subscription: this.getSubscriptionParams() };
    this.subscriptionForm.serializeArray().forEach(function (fieldData) {
      params[fieldData.name] = fieldData.value;
    });

    $.post(this.routes.submitSubscription, params, this.handleResponse);
  };

  CheckoutFormHandler.prototype.handleResponse = function (data) {
    if (data.status === 'success') {
      document.location.href = data.redirect_to;
    }
    else {
      $('#update_messages').displayMessage('error', data.errors);
    }
  };

  return CheckoutFormHandler;
});
