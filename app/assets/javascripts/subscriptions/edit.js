define(['jquery', 'subscriptions/checkout_form_handler', 'lib/jquery.stylableselect', 'lib/jquery.colorbox'], function ($, CheckoutFormHandler) {

  return {
    init: function (settings) {
      var subscriptionDummyForm = $('#subscription_dummy_form');

      checkoutForm = new CheckoutFormHandler({
        dummyForm: subscriptionDummyForm,
        subscriptionForm: $('#edit_subscription'),
        routes: settings.routes
      });

      subscriptionDummyForm.find('select')
        .change(function () { checkoutForm.refreshTotals(); })
        .stylableSelect();

      $('#subscription_submit').click(function (event) {
        event.preventDefault();
        checkoutForm.submitSubscription();
      });

      // Refresh totals right away
      checkoutForm.refreshTotals();

      // Enable cancel link
      $('#cancel-link').click(function (event) {
        event.preventDefault();

        $.colorbox({
          href: $(this).attr('href'),
          width: 450
        });
      });

      // 'Do not cancel' modal link event binding
      $('#close-current-modal').live('click', function (event) {
        event.preventDefault();
        $.colorbox.close();
      });
    }
  };
});
