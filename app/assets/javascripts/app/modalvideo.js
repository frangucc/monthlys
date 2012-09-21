define(['jquery', 'lib/jquery.colorbox'], function ($) {
  $('a.modal-video')
    .colorbox({
      fixed: true,
      iframe: true,
      title: '&nbsp;',
      innerWidth: 638,
      width: 638,
      innerHeight: 400,
      height: 400,
      transition: 'none',
      onOpen: function () {
        window.holdResizeColorbox = true;
      },
      onClose: function () {
        window.holdResizeColorbox = false;
      }
    });
});
