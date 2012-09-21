define(['jquery', 'lib/jquery.infieldlabel'], function ($) {

  return {
    init: function () {
      $('.settings-form .last label, .settings-form .first label').inFieldLabels();
    }
  };
});
