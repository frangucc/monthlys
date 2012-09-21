define(['jquery', 'app/ajax_signup'], function ($, AjaxSignup) {

  /**
   *
   */
  $(function () {
    if (user.signed_in === false) {
      AjaxSignup.configure({ enableClose: false });
      AjaxSignup.signUp(function () {
        window.location.href = window.location.href;
      });
    }
  });

});
