/*jslint indent: 4 */
/*global define*/

define(['jquery', 'dojo/_base/lang', 'widgets/autosuggest'], function ($, lang) {
    'use strict';

    $.fn.categoriesSuggest = function (options) {
        var settings = $.extend({
                url: '/mp/categories/',
                // You usually want to override this, it shoud be a comma separated values string
                initial: ''
            }, options);

        $.get(settings.url, { ids: settings.initial }, lang.hitch(this, function (data) {
            this.autoSuggest(settings.url, {
                selectionLimit: 3,
                limitText: 'Only <b>3 categories</b> can be selected.',
                selectedItemProp: 'name',
                selectedValuesProp: 'id',
                searchObjProps: 'name',
                queryParam: 'name',
                preFill: data
            });
        }));
    };
});
