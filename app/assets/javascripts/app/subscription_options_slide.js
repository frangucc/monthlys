define('subscription_options_slide', ['jquery'], function ($) {

  /*
   * Options slide for each subscription.
   */
  $('article.subscription').each(function () {
    var $this = $(this)
      , options = $this.find('section.subscription-options')
      , handle = options.find('h1')
      , options = options.find('ul.options')
      , price = $this.find('p.price strong')
      , total = $this.find('p.total strong:eq(1)')
      , priceValue = price.html()
      , totalValue = total.html();

      if (!options.length) { return };

      function hide() {
        handle.removeClass('open').addClass('closed');
        handle.html('Show options');
        options.stop().slideUp();
        // price.html(totalValue);
        // total.parent().stop(true, true).fadeOut();
      }

      function show() {
        handle.removeClass('closed').addClass('open');
        handle.html('Hide options');
        options.stop().slideDown();
        // total.html(totalValue);
        // price.html(priceValue);
        // total.parent().stop(true, true).fadeIn();
      }

      function toggle() {
        if (handle.is('.open')) {
          hide();
        }
        else {
          show();
        }
      }

      hide();
      handle.css('cursor', 'pointer');

      handle.click(toggle);
  });

});
