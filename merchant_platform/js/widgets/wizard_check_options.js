define(['jquery'], function ($) {
    function reflectSelecteted () {
        $('.wizard-check-options .option')
            .has('input:checked')
            .addClass('selected');

        $('.wizard-check-options .option.selected')
            .has('input:not(:checked)')
            .removeClass('selected');
    }

    function init () {
        $('.wizard-check-options .option input')
            .bind({ change: reflectSelecteted });

        $('.wizard-check-options .option').bind({
            click: function (e) {
                e.preventDefault();
                var opt = $(this);
                var input = opt.find('input');

                input.prop('checked', !input.prop('checked')).change();
            }
        }); 

        reflectSelecteted();
    }

    return init;
});
