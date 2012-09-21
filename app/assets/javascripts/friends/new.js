define(['jquery', 'app/ajax_signup', 'lib/jquery.infieldlabel'], function ($, AjaxSignUp) {

  return {
    init: function () {
      $('section.form label').inFieldLabels();
      $('#friends_new').submit(function (event) {
        if (!userSignedIn) {
          event.preventDefault();

          var $friendsForm = $(this);
          AjaxSignUp.signUp(function () {
            userSignedIn = true;
            $friendsForm.submit();
          });
        }
      });
    }
  };
});
