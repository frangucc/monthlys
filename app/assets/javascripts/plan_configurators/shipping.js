define(['jquery', 'plan_configurators/refresh_totals', 'debug', 'app/messages'], function ($, totals, debug) {
  if (show_form.shipping_select) {
    var new_shipping_radio = $('ul.shipping-infos > li.new-shipping-info > input[type=radio]'),
        lis = $('ul.shipping-infos > li'),
        form = $('#shipping-info-address');

    if (($('li.shipping-info:not(.disabled)').length !== 0) &&
        ($('li.new-shipping-info .flash-error').length === 0)) {

      $('ul.shipping-infos > li > input[type=radio]').change(function (event) {
        if ($(this).is(':checked')) {

          // update status classes
          lis.removeClass('selected');
          $(this).parent().addClass('selected');

          // refresh totals
          $('#subscription_shipping_info_id').val($(this).val());
          totals.refresh();
        }

        form.toggle(new_shipping_radio.is(':checked'));
      }).change();

    }
    else if ($('li.new-shipping-info .flash-error').length !== 0) {
      $('ul.shipping-infos input[type=radio]').val(['']);
    }

  }
  else if (show_form.shipping){
    // Single new shipping info form
    $('#shipping-info-address').hide();
    $('#copy_shipping_info').change(function (event) {
      $('#shipping-info-address').toggle(!$(this).is(':checked'));
      $('#ship-to-personal-address').toggle($(this).is(':checked'));
    }).change();
  }

  $('.address-fields input').change(function (event) {
    $(this).parent().removeClass('error');
  });
});
