define(['jquery', 'lib/jquery.carouFredSel'], function ($) {
  $.fn.multislider = function(options) {
    var settings, $this;

    settings = $.extend({
      cls: 'multislider',
      carouselOptions: {
        items: { visible: 5 },
        scroll: { items: 3, duration: 1500 },
        auto: 5000
      }
    }, options);

    $this = $(this);

    $this.each(function (index, element) {
      var carousel, wrapper, wrapperCls, wrapperClsIdx, carouselOpts;

      wrapperCls = settings.cls;
      wrapperClsIdx = wrapperCls + '-' + index;

      carouselOpts = $.extend(settings.carouselOptions, {
        prev: '.' + wrapperClsIdx + ' .prev',
        next: '.' + wrapperClsIdx + ' .next'
      });

      wrapper = $("<div></div>").addClass(wrapperCls + ' ' + wrapperClsIdx);
      items = $(element).after(wrapper).detach();

      wrapper
        .append('<a href="#" class="prev"><span></span></a>')
        .append(items)
        .append('<a href="#" class="next"><span></span></a>');

      items.carouFredSel(carouselOpts);
    });

    return $this;
  };
});
