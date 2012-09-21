/*jslint indent: 2 */
/*global $,require,window,setTimeout*/
define(['jquery', 'app/background', 'app/in_field_label', 'app/modalvideo'], function () {
  'use strict';

  var form = $('.authentication-frame').add('.video-wrapper');

  $(window).load(function () {
    $(".authentication-frame, .static-page-container").equalHeight();
  });

  $(window).resize(function () {
    $(".authentication-frame, .static-page-container").equalHeight();
  });

  $.fn.equalHeight = function () {
    var reset, height = 0;

    reset = $.browser.msie ? "1%" : "auto";

    return this
      .css("height", reset)
      .each(function () {
        height = Math.max(height, this.offsetHeight);
      })
      .css("height", height)
      .each(function () {
        var h = this.offsetHeight;
        if (h > height) {
          $(this).css("height", height - (h - height));
        }
      });
  };

  /**
   * When the video is open the form must
   * disappear and the background must stop
   * rotating.
   */
  function openVideo() {
    window.rotate = false;
    form.animate({
      opacity: 0
    }, {
      complete: function () {
        $(this).css('visibility', 'hidden');
      }
    });
  }
  $('a.modal-video').bind('cbox_open', openVideo);

  /**
   * Then when closed all needs to go back to normal.
   */
  function closeVideo() {
    window.rotate = true;

    if (window.initBackgroundRotation) {
      window.initBackgroundRotation();
    }

    setTimeout(function () {
      form
        .css('visibility', 'visible')
        .animate({ opacity: 1 });
    }, 500);
  }
  $('a.modal-video').bind('cbox_closed', closeVideo);

  $('header.main nav li.last').prev().click(function (event) {
    if ($(this).find('a').html() === 'Sign In') {
      signIn();
    } else {
      signUp();
    }
    event.preventDefault();
  });

});
