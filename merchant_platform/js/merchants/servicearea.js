/*jslint indent: 4 */
/*global define,$*/

define(['common', 'dojo/_base/lang', 'widgets/completion_box'], function () {
    'use strict';

    $('.optionsbox').each(function () {
        var box = $(this);

        box.optionsBox({
            togglerField: box.find('input[type="radio"]'),
            url: box.data('url'),
            dscAttr: box.data('dscattr') || 'name'
        });
    });
});
