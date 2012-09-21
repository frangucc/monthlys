/*jslint indent: 2*/
/*global define*/
define(['jquery', 'lib/jquery.colorbox'], function ($) {
  'use strict';

  return {
    init: function (settings) {

      $(document).ready(function () {
        $(settings.selector).on('click', function (event) {
          event.preventDefault();
          $.colorbox({
            html: '<iframe src="' + $(this).data('video-url') + '" width="450" height="365" frameborder="0" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>'
          });
        });
      });
    }
  };
});
