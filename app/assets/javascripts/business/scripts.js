define(['jquery', 'lib/jquery.colorbox', 'app/in_field_label'], function ($) {
  "use strict"

  /**
   * Setup videos
   */
  var $this;
  $('.video-popup').each(function () {
    $this = $(this);
    $this
      .css('cursor', 'pointer')
      .colorbox({
        href: $this.attr('data-youtube'),
        fixed: true,
        maxWidth: '100%',
        iframe: true,
        innerWidth: 638,
        innerHeight: 400,
        transition: 'none'
      });
  });

  /**
   * Merchants categories
   */
  $('body.business-merchants').each(function () {
    $('.showcase li:gt(0)').hide();
    $('.categories li:eq(0)').addClass('active')

    // Play buttons show iframes.
    $('.showcase .play').click(function () {
      var li = $(this).parent().parent();
      // Hide image.
      li.find('img').hide();
      // Show iframe.
      li.find('figure').prepend(li.data('video'));
      // Remove play buttons
      $('.showcase .play').remove();
      return false;
    });

    // Save all iframe elements as data into the figure
    // so I can remove them from the document to stop
    // playing and then put them in again.
    $('.showcase li').each(function () {
      $(this).data('video', $(this).find('iframe').remove().css('display', 'block'));
    });

    $('.categories li a').click(function () {

      // Remove all the "active" classes and set it to the
      // item clicked.
      var $this = $(this);
      $this
        .parent()
        .parent()
        .find('li')
          .removeClass('active')
          .filter($this.parent())
          .addClass('active');

      // Run a fade out animation of the visible frame and
      // a fade in on the frame that will become visible.
      // Once the video is displayed, show the video playing
      // as soon as possible.
      $('.showcase li:visible')
        .stop(true, true)
        .animate({
          top: -600,
          opacity: 0
        }, {
          duration: 300,
          complete: function () {

            // This is the li element that will be shown.
            var newVisible = $('.showcase li').eq($this.parent().index());

            // Hide the current frame.
            // And remove video.
            $(this)
              .hide()
              .find('iframe').remove();

            // Fade in the new frame.
            newVisible
              // Find and hide the image in the new visible frame.
              .find('img').hide()
              // Add the iframe to the figure
              .parent().prepend(newVisible.data('video'))
              // Go back up to the li element and run the animation
              // that will put it on screen.
              .parent()
              .css({
                top: -600,
                opacity: 0
              })
              .stop(true, true)
              .show()
              .animate({
                top: 0,
                opacity: 1
              }, {
                duration: 600
              });

          }
        });

      // Remove play buttons.
      $('.showcase .play').remove();

      // Cancel default click functionallity.
      return false;
    });
  });

  /**
   * Platform flexslider
   */
  $('body.business-platform').each(function () {
    var lis = $('h1 + ul li'); // li tags right after the heading.
    lis.find('a').click(function () {
      var index = $(this).parent().index();
      $('.flexslider .flex-control-nav li').eq(index).find('a').click();
      return false;
    });
    $('section.tour p:gt(0)').hide();
    $('.flexslider').flexslider({
      animation: 'slide',
      slideshow: false,
      /*
       * Update the tour navigation when the slide starts to change.
       */
      before: function (slide) {
        lis.removeClass('selected')
          .eq(slide.animatingTo)
          .addClass('selected');
        $('section.tour p').hide()
          .eq(slide.animatingTo).show();
      }
    });
  });

  /**
   * In-field labels in merchants#new form
   */
  $('body.merchants-new, body.merchants-create').each(function () {
    $('section.form')
      .find('div.firstname, div.lastname, div.zip')
      .find('label')
        .inFieldLabels();
  });

});
