define(['jquery', 'lib/jquery.carouFredSel', 'lib/jquery.ui'], function ($) {

  // Small highlights block
  var itemsSel = '.small-highlights .items',
      carouselCls,
      carouselOpts;

    $(itemsSel).each(function (index, element) {

    carouselCls = 'carousel-' + index,

    carouselOpts = {
      items: {
        visible: 5
      },
      scroll: {
          items: 4,
        duration: 1500
      },
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

  // Big highlights
  $('.big-highlights').tabs({
    fx: { opacity: "toggle" }
  });
});
