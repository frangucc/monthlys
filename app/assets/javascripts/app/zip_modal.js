define(['app/ajax_signup'], function (AjaxSignup) {

  var settings;

  /**
   *
   */
  function submitZipcodeFormByAjax(form) {
    var url = [form.attr('action'), form.serialize()].join('?');
    $.post(url, { dataType: 'script' });
  }

  /**
   * Show the zipcode modal
   */
  function askForZipcode() {
    $('#zip-modal').show();
    $.colorbox({
      html: $('#zip-modal'),
      innerWidth: 400,
      fixed: true,
      onOpen: function () {
        // Binding events
        $('#enter_zip_form label').inFieldLabels();
        $('#enter_zip_form .signin').click(function (event) {
          event.preventDefault();
          AjaxSignup.signUp();
        });
        $('#enter_zip_form').submit(function (event) {
          event.preventDefault();
          submitZipcodeFormByAjax($(this));
        });
      },
      onClosed: function () {
        $.get('/settings/persistent_dismiss?name=zipcode_prompt');
      }
    });
  }

  return {
    init: function (context) {
      settings = context || {};
      if (settings.askForZipcode) {
        askForZipcode();
      }
    }
  };

});
