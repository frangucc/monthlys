/*jslint indent: 2 */
/*global define,clearTimeout,setTimeout*/

define(['jquery', 'lib/jquery.carouFredSel', 'lib/jquery.ui'], function ($) {
  'use strict';

  // Main Slider
  var section = $('#main-slider'),
    articles = section.find('.bottles'),
    items = section.find('ul.nav li'),
    count = items.length,
    current = items.length,
    animationSpeed = 400,
    animationSpeed2 = 800,
    rotate,
    rotationSpeed = 7000 + animationSpeed2; // 7 seconds between items

  function hideAll(callback) {
    articles.filter('.selected').find('img').animate({
      opacity: 0
    }, {
      duration: animationSpeed2,
      complete: function () {
        callback();
      }
    });
    articles.removeClass('selected');
  }

  function show(article) {
    article.addClass('selected');
    article.find('img').animate({
      opacity: 1
    }, {
      duration: animationSpeed
    });
  }

  function select(i) {
    current = i;
    items.removeClass('selected').eq(i).addClass('selected');

    hideAll(function () {
      show(articles.eq(i));
    });
    scheduleNext();
  }

  function stop() {
    clearTimeout(rotate);
  }

  function next() {
    current = (current + 1) % count;
    select(current);
  }

  function scheduleNext() {
    clearTimeout(rotate);
    rotate = setTimeout(next, rotationSpeed);
  }

  items.click(function () {
    select($(this).index());
  });
  articles.bind({
    mouseover : stop,
    mouseout  : scheduleNext
  });
  articles.find('img').css({
    opacity: 0
  });

  next();

  // What went out slider

  function initSlider() {
    var carouselOpts;

    carouselOpts = {
      items: { visible: 3 },
      scroll: { items: 2, duration: 1500 },
      auto: 5000,
      direction: 'left',
      prev: '#catalogue .prev',
      next: '#catalogue .next'
    };

    $('#catalogue ul')
      .before('<a href="#" class="prev"></a>')
      .after('<a href="#" class="next"></a>')
      .carouFredSel(carouselOpts);
  }

  initSlider();

});
