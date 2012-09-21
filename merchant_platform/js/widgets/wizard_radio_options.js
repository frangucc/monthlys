define(['jquery'], function ($) {

  function reflectSelecteted() {
    $('.wizard_radio_options .option')
      .removeClass('selected')
      .has('input:checked')
      .addClass('selected');
  }

  function init() {
    $('.wizard_radio_options .option input')
      .bind({ change: reflectSelecteted })
      .filter(':eq(0)')
      .attr('checked', 'checked');

    $('.wizard_radio_options .option').bind({
      click: function () {
        $(this).find('input')
          .attr('checked', 'checked')
          .change();
      }
    }); 

    reflectSelecteted();
  }
  
  return init;

});
