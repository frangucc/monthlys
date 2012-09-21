/*jslint indent: 2*/
/*global $,define,window,setTimeout*/
define(['jquery'], function ($) {
  'use strict';

  var imgContainer = $('div.bg-wrapper'),
    img = imgContainer.find('img'), // Currently loaded image.
    count = 16,
    current = Math.round(Math.random() * count),
    rotate = true;


  /**
   * Calculates the size based on the viewport.
   * The img variable must contain the image to calculate
   * the size from.
   * @returns   {Object}   sizes
   */
  function calculateSize() {
    // get viewport and image size
    var viewport = {
        width: $(window).width(),
        height: $(window).height()
      },
      image = {
        width: img.width(),
        height: img.height()
      },
      calc = {};

    // See if higher or wider
    if (viewport.width / viewport.height <= 1.5) {
      // Higher: size is based in height
      calc.height = viewport.height;
      calc.width = viewport.height * 1.5;
    } else {
      // Wider: size is based in width
      calc.width = viewport.width;
      calc.height = viewport.width / 1.5;
    }
    // Calculate left to center the image into the viewport
    calc.left = (calc.width - viewport.width) / 2;

    return calc;
  }

  /**
   * Takes the currently loaded image and applies the
   * calculated size.
   */
  function resize() {
    var size = calculateSize();
    img.css({
      width: size.width,
      height: size.height,
      left: size.left * -1
    });
  }

  /**
   * Increases the count and loads the next image.
   */
  function nextImage() {
    // current + 1 % count
    current = (current + 1) % count;
    // load image
    loadImage('/assets/default/default_backgrounds/background_' +
      current + '.jpg');
  }

  /**
   * Appends the image with the calculated size.
   * Calls the nextImage method again if rotation is needed.
   * this -> image tag
   */
  function loadImageCallback() {
    var current = imgContainer.find('img:last');

    // append
    img
      .prependTo(imgContainer)
      .addClass('bg')
      .css('left', (current.width() + 'px'));

    // hide and remove front image
    current
      .animate({
        left: (current.width() * -1)
      }, {
        complete: function () {
          $(this).remove();
        },
        easing: 'swing',
        duration: 300
      });
    img
      .animate({
        left: 0
      }, {
        easing: 'swing',
        duration: 300
      });
    // resize image
    resize();
    // if rotate, nextImage
    if (rotate) {
      setTimeout(nextImage, 8000);
    }
  }

  /**
   * Creates a DOM image and set handlers for onload.
   * @param   {String}   url
   */
  function loadImage(url) {
    // create img and add handler
    img = $('<img />')
      .attr('src', url)
      .load(loadImageCallback);
  }

  /**
   * Checks the document state and launches accordingly.
   */
  function init() {
    // if bg and not city image, rotate
    var img = imgContainer.find('img');
    resize();
    $(window).resize(function () {
      resize();
    });
    if (img.hasClass('bg') && !img.hasClass('city_image') && !$("body").hasClass('merchant')) {
      nextImage();
    }
  }

  window.initBackgroundRotation = init;

  init();

});
