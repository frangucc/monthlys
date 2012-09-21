/*jslint indent: 4 */
/*global define*/

define(['common'], function () {
    $('input[name="discount_type"]').change(function () {
        if ($(this).val() === 'percent') {
            $('.discount_in_usd').hide();
            $('.discount_percent').show();
        } else {
            $('.discount_percent').hide();
            $('.discount_in_usd').show();
        }
    }).change();
});

