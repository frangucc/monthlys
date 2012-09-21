define(['jquery'], function ($) {

  /**
   * Terms and conditions window
   */
  function termsAndConditionsConfirmation() {
    var terms_href = '/merchants/' + merchant.id + '/terms';
    $.colorbox({
      href: terms_href,
      width: 700,
      height: 390,
      fixed: true,
      onComplete: function () {
        $('#accept-terms-and-conditions').click(function (event) {
          event.preventDefault();
          $('#accept_terms').attr('checked', 'checked');
          $.colorbox.close();
        });
      }
    });
  }

  // Terms and conditions forms
  $('.terms-and-conditions').click(function (event) {
    event.preventDefault();
    termsAndConditionsConfirmation();
  });

  return {
    isTermsAccepted: function () {
      var isTermsAccepted = !merchant.has_terms || $('#accept_terms').is(':checked');

      if (!isTermsAccepted) {
        $('.messages').displayMessage('flash-error terms-error', "Please accept " + merchant.business_name + "'s terms and conditions first.");
      }
      else {
        $('.messages').children('.terms-error').remove();
      }

      return isTermsAccepted;
    }
  };

});
