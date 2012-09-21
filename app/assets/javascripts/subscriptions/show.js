define(['jquery', 'app/subscription_options_slide'], function ($) {

  // invoices accordion
  (function () {
    var invoices = $('section.invoices li.invoice')
      , handles = invoices.find('h2.date');

    function closeAll() {
      invoices.removeClass('open').addClass('closed');
    }

    function open(i) {
      invoices.eq(i).removeClass('closed').addClass('open');
    }

    function close(i) {
      invoices.eq(i).removeClass('open').addClass('closed');
    }

    function toggle(i) {
      if (invoices.eq(i).is('.open')) {
        close(i);
      }
      else {
        open(i);
      }
    }

    closeAll();

    handles
      .css('cursor', 'pointer')
      .click(function () {
        toggle($(this).parent().index());
      });
  }());

  // invoices print links
  $('section.invoices li.invoice a.print').click(function () {
    window.print();
    return false;
  });

  $('.subscription-actions .reactivate').click(function (event) {
    event.preventDefault();

    $.colorbox({
      href: $(this).attr('href'),
      width: 700
    });
  });

});
