define(['jquery'], function ($) {

  /**
   * Bind the close action to the get started banner close button
   */
  function bindGetStartedCloseButton() {
    // Get started banner hide and save in session
    $('section.get_started .close').click(function () {
      $('section.get_started').hide(700, function () {
        $(this).remove();
      });
      $.get('/settings/persistent_dismiss?name=get_started');
      return false;
    });
  }

  return {
    init: function () {
      bindGetStartedCloseButton();
    }
  };

});
