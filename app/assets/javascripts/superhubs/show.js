define(['jquery', 'lib/jquery.carouFredSel', 'lib/jquery.ui'], function ($) {
  // Primary highlights
  $('.primary-highlight').tabs({
    fx: { opacity: "toggle" }
  });

  // Tertiary highlights
  var itemsSel = '.tertiary-highlight .items',
      carouselCls,
      carouselOpts;

  $(itemsSel).each(function (index, element) {
    carouselCls = 'carousel-' + index,

    carouselOpts = {
      items: { visible: 4 },
      scroll: { items: 2, duration: 1500 },
      auto: 5000,
      prev: '.' + carouselCls + ' .prev',
      next: '.' + carouselCls + ' .next',
    }

    $(element)
      .parent('section')
      .addClass(carouselCls)
      .end()
      .before('<a href="#" class="prev"></a>')
      .after('<a href="#" class="next"></a>')
      .carouFredSel(carouselOpts);
  });
});
