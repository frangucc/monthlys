define(['jquery'], function ($) {

  $('section.header_promo a.dismiss').click(function () {
    $('section.header_promo').remove();
    $.get('/settings/persistent_dismiss?name=header_promo');
    return false;
  });

});
