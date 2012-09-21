/*jslint indent: 2*/
/*global define,setTimeout*/
define(['jquery'], function ($) {
  'use strict';

  function ImageSlider(container) {
    this.container = container;
    this.activeImage = null;
    this.activeThumb = null;
  }


  ImageSlider.prototype.init = function () {
    this.initDom();
  };


  ImageSlider.prototype.initDom = function () {
    this.initImages();
    this.initSlider();
    this.initThumbnails();
    this.initArrows();
  };

  ImageSlider.prototype.initImages = function () {
    var images;

    images = this.container.find('img')
      .wrap($('<div class="image-wrapper"/>'));

    this.images = this.container.find('.image-wrapper').hide();

    this.images.each(function () {
      var caption = $(this).children('img').attr('data-image-slider-caption');
      if (caption) {
        $('<p class="caption">' + caption + '</p>').appendTo($(this));
      }
    });

    this.imagesWrapper = $('<div class="images-wrapper"/>');
    this.images
      .wrapAll(this.imagesWrapper);

    this.activeImage = this.images.eq(0);
    this.activeImage.show();
  };


  ImageSlider.prototype.initSlider = function () {
    this.sliderWrapper = $('<div class="plan-image-carousel"/>')
      .appendTo(this.container);
    this.slide = $('<div class="slide"/>').appendTo(this.sliderWrapper);
    this.frame = $('<div class="frame"/>').appendTo(this.slide);
  };


  ImageSlider.prototype.initThumbnails = function () {
    var image, thumbWrapper, caption;

    this.images.each($.proxy(function (i, element) {
      image = $(element).find('img');

      thumbWrapper = $('<div class="thumbnail"/>');

      $('<img/>')
        .attr({ src: image.attr('src') })
        .appendTo(thumbWrapper);

      caption = image.attr('data-image-slider-thumb-caption');
      if (caption) {
        $('<p class="caption">' + caption + '</p>').appendTo(thumbWrapper);
      }

      thumbWrapper
        .on('click', this.getThumbClickHandler(i))
        .appendTo(this.frame);

      if (i === 0) {
        this.activeThumb = thumbWrapper;
        this.activeThumb.addClass('selected');
      }
    }, this));

    this.thumbs = this.container.find('.thumbnail');
    this.slide.css('width', (this.thumbs.length * 98) + 'px');
  };


  ImageSlider.prototype.getThumbClickHandler = function (idx) {
    return $.proxy(function (e) {
      e.preventDefault();
      this.switchTo(idx);
    }, this);
  };


  ImageSlider.prototype.switchTo = function (idx) {
    var image, thumb;

    image = this.images.eq(idx);
    if (image === this.activeImage) {
      return;
    }

    thumb = this.thumbs.eq(idx);

    image.css({ left: '700px', opacity: 0 });
    this.activeImage
      .stop(true, true)
      .animate({ left: '-700px', opacity: 0 }, {
        duration: 200,
        complete: function () {
          $(this).hide();
          image.show().stop(true, true)
            .animate({ left: '0px', opacity: 1 }, { duration: 200 });
        }
      });

    this.activeImage = image;

    this.activeThumb.removeClass('selected');
    this.activeThumb = thumb;
    this.activeThumb.addClass('selected');
  };


  ImageSlider.prototype.initArrows = function () {
    this.prev = $('<a href="#" class="prev"/>')
      .click(this.getArrowClickHandler('right')).appendTo(this.sliderWrapper);

    this.next = $('<a href="#" class="next"/>')
      .click(this.getArrowClickHandler('left')).appendTo(this.sliderWrapper);

    // FIXME: Hack: Wait for the dom to be fully load. Ajax based sliders
    // have some issues.
    if (!parseInt(this.slide.css('left'), 10) || !parseInt(this.sliderWrapper.css('width'), 10)) {
      setTimeout($.proxy(function () { this.checkSlideBounds(); }, this), 400);
    } else {
      this.checkSlideBounds();
    }
  };


  ImageSlider.prototype.getArrowClickHandler = function (direction) {
    return $.proxy(function (e) {
      e.preventDefault();
      this.slideTo(direction);
    }, this);
  };


  ImageSlider.prototype.slideTo = function (direction) {
    var currentLeft, newLeft, thumbWidth, directionSign;

    thumbWidth = 98;
    directionSign = (direction === 'left') ? -1 : 1;

    currentLeft = parseInt(this.slide.css('left'), 10);
    newLeft = currentLeft + (thumbWidth * directionSign);

    this.slide.animate({ left: (newLeft + "px") }, {
      duration: 50,
      complete: $.proxy(function () {
        this.checkSlideBounds();
      }, this)
    });
  };


  ImageSlider.prototype.checkSlideBounds = function () {
    var arrowWidth, initialLeft, currentLeft, slideWidth, sliderWrapperWidth;

    currentLeft = parseInt(this.slide.css('left'), 10);
    sliderWrapperWidth = parseInt(this.sliderWrapper.css('width'), 10);
    arrowWidth = 28;
    initialLeft = arrowWidth;
    slideWidth = parseInt(this.slide.css('width'), 10);


    // Check prev arrow
    if (currentLeft >= initialLeft) {
      this.prev.addClass('disabled').off('click').on('click', function (e) { e.preventDefault(); });
    } else if (this.prev.hasClass('disabled')) {
      this.prev.removeClass('disabled').on('click', this.getArrowClickHandler('right'));
    }

    // Check next arrow
    if (slideWidth + currentLeft <= sliderWrapperWidth - arrowWidth) {
      this.next.addClass('disabled').off('click').on('click', function (e) { e.preventDefault(); });
    } else if (this.next.hasClass('disabled')) {
      this.next.removeClass('disabled').on('click', this.getArrowClickHandler('left'));
    }

  };

  return ImageSlider;
});
