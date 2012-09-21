define(['jquery'], function ($) {

  /*
   * Main banner
   */
  (function () {

    var current = 0
      , articles = $('section.plan-slider article')
      , count = articles.length
      , rotateTimeout = null
      , locked = false;

    // do nothing if there's only one article;
    if (articles.length === 1) {
      $('section.plan-slider a.arrow').remove();
      return;
    }

    // define animation ins and outs
    function hideVisible() {
      articles.find('img').animate({
        opacity: 0
      }, {
        complete: function () {
          $(this).hide();
        }
      });
      articles.find('.plan-info').animate({
        right: -100,
        opacity: 0
      }, {
        duration: 1000,
        complete: function () {
          $(this).hide();
        }
      });
    }
    function show(index) {
      var article = articles.eq(index);

      hideVisible();
      current = index;

      article.find('img').stop(true, true).show().animate({
        opacity: 1
      }, {
        duration: 1000
      });
      article.find('.plan-info').stop(true, true).show().animate({
        right: 0,
        opacity: 1
      }, {
        duration: 1500
      });
    }

    // define rotation and sequence playing
    function rotate() {
      clearTimeout(rotateTimeout);
      rotateTimeout = setTimeout(next, 8000);
    }
    function next() {
      current = (current + 1) % count;
      show(current);
      rotate();
    }

    // apply handlers
    $('section.plan-slider').bind({
      mouseover: function () {
        clearTimeout(rotateTimeout);
      },
      mouseout: function () {
        rotate();
      }
    });
    $('section.plan-slider a.arrow').click(function () {
      next();
      return false;
    });

    // show first
    articles.eq(0).addClass('selected');
    articles.filter(':gt(0)').find('img').css({ opacity: 0 }).hide();
    articles.filter(':gt(0)').find('.plan-info').css({ right: -100, opacity: 0 }).hide();
    rotate();

  }());

});
