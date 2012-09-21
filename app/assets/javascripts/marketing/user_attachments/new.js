/*jslint indent: 2*/
/*global define*/
define(['jquery', 'lib/jquery.carouFredSel', 'lib/jquery.infieldlabel'], function ($) {
  'use strict';

  function initSlider() {
    var carouselOpts;

    carouselOpts = {
      items: { visible: 1 },
      scroll: { items: 1, duration: 1500 },
      auto: 5000,
      direction: 'left',
      prev: '#slider .prev',
      next: '#slider .next'
    };

    $('#slider ul')
      .before('<a href="#" class="prev"></a>')
      .after('<a href="#" class="next"></a>')
      .carouFredSel(carouselOpts);
  }


  function initForm() {
    $('#stickit-form label').inFieldLabels();
  }


  function init() {
    $(function () {
      initForm();
      initSlider();
    });
  }

  return { init: init };

});
