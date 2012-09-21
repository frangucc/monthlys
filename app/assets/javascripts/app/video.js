define('video', ['jquery'], function ($) {

  var $a = $('a.how-it-works'),
      $form = $('.authentication-frame'),
      title = $a.attr('title');
  $a
    .colorbox({
      fixed: true,
      title: title,
      innerWidth: 800,
      maxWidth: '100%',
      iframe: true,
      innerWidth: 638,
      innerHeight: 400,
      onOpen: openVideo,
      onClosed: closeVideo,
      transition: 'none'
    });

  /**
   * When the video is open the form must
   * disappear and the background must stop
   * rotating.
   */
  function openVideo() {
    window.rotate = false;
    $form.animate({ opacity: 0 });
  }

  /**
   * Then when closed all needs to go back to normal.
   */
  function closeVideo() {
    window.rotate = true;
    window.initBackgroundRotation();
    setTimeout(function () {
      $form.animate({ opacity: 1 });
    }, 500);
  }

});
