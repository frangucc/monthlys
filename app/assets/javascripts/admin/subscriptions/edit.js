(function () {
  var urlData = $('.formtastic.subscription').attr('action').split('/')
    , subscriptionId = urlData[urlData.length - 1]
    , submitBtn = $('#subscription_submit')
    , pricingLabel = $('fieldset.inputs:last legend span');

  var getOptionsId = function () {
    var optionsId, optionsSelect;

    optionsId = [];
    optionsSelect = $('.option-group select');

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

  var ajaxSucces = function (data) {
    // Base amount
    $('#base-amount').html('$ ' + data.base_amount + ' ' + data.billing_desc);
    // Recurrent total
    $('#recurrent-total').html('$ ' + data.recurrent_total + ' ' + data.billing_desc);

    // Options
    if (data.options_total) {
      $('#options-total').html('$ ' + data.options_total);
    }
    else {
      $('#options-total').html('$ 0.00');
    }

    // Shipping
    if (data.recurrent_shipping) {
      $('#recurrent-shipping').html('$ ' + data.recurrent_shipping);
    }
    else {
      $('#recurrent-shipping').html('$ 0.00');
    }

    // Taxes
    if (data.recurrent_tax) {
      $('#recurrent-taxes').html('$ ' + data.recurrent_tax);
    }
    else {
      $('#recurrent-taxes').html('$ 0.00');
    }

    pricingLabel.html('Pricing');
    submitBtn.show();
  };

  var refreshTotals = function () {
    var subscriptionParams = {
      plan_recurrence_id: $('#subscription_plan_recurrence_id').val(),
      shipping_info_id: $('#subscription_shipping_info_id').val(),
      options_id: getOptionsId()
    };
    submitBtn.hide();
    pricingLabel.html('Pricing (Loading..)');
    $.get('/admin/subscriptions/' + subscriptionId + '/refresh_totals?' + $.param({ subscription : subscriptionParams }), ajaxSucces);
  };

  $('.formtastic.subscription select').change(refreshTotals);

  refreshTotals();

}());
