define(['jquery', 'lib/jquery.colorbox'], function ($) {

  return {
    init: function () {
      $('.subscription-actions .reactivate').click(function (event) {
        event.preventDefault();

        $.colorbox({
          href: $(this).attr('href'),
          width: 700
        });
      });
    }
  };
});
