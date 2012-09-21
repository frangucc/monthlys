define('settings_navigation', ['jquery'], function ($) {

  $('ul.navigation p')
    .addClass('clickable')
    .click(function () {
      $(this).toggleClass('closed').next().toggle();
    })
    .click();

});
