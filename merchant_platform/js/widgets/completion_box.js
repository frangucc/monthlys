/*jslint indent: 4 */
/*global define,_*/
define(['jquery', 'dojo/_base/lang', 'lib/underscore-min'], function ($, lang) {
    'use strict';

    $.fn.optionsBox = function (options) {
        var settings = $.extend({
                url:            '',
                togglerField:   null,
                idAttr:         'id',    // attribute in json result that represents the item ID
                dscAttr:        'name'   // attribute in json result that represents the item description
            }, options),
            self = $(this),
            listEl = $('<div>').addClass('optionsbox-items-list'),
            inputEl = self.find('.optionsbox-input'),
            hiddenField = self.find('input[type="hidden"]'),
            params;

        if (!settings.togglerField) {
            throw('optionsBox: check your settings, "togglerField" is required.');
        }

        listEl.css({
            'display': 'none',
            'position': 'absolute',
            'margin-top': '11px'
        });
        listEl.append('<ul>');
        inputEl.after(listEl);

        var setItemsIds = function (items) {
            hiddenField.data('optionsbox-items', items);
            hiddenField.val(items.join(','));
        };

        var showItem = function (item) {
            var itemEl, removeEl, items,
                itemId = item[settings.idAttr],
                el = $('<div>').addClass('optionsbox-item');

            if ($('#' + el.attr('id')).size() === 0) {
                itemEl = $('<span>').addClass('optionsbox-item-description')
                                    .html(item[settings.dscAttr]);
                removeEl = $('<a>').attr('href', '#')
                                   .addClass('optionsbox-remove')
                                   .html('&times;').click(function (e) {
                                       e.preventDefault();
                                       el.remove();
                                       setItemsIds(_.without(hiddenField.data('optionsbox-items'), itemId));
                                   });

                items = hiddenField.data('optionsbox-items') || [];

                if (items.indexOf(itemId) < 0) {
                    el.append(itemEl);
                    el.append(removeEl);

                    self.find('.optionsbox-items').append(el);

                    // Store items ids in hidden field
                    setItemsIds(_.union(items, [itemId]));
                }

                // clear input value for further input
                inputEl.val('');
                listEl.hide();
            }
        };

        var showItemsList = function (items) {
            var liEl, aEl, ulEl = listEl.find('ul');

            ulEl.html('');

            if (items.length > 0) {
                _(items).each(function (item) {
                    liEl = $('<li>');
                    aEl = $('<a>');

                    aEl.attr('href', '#').click(function (e) {
                        e.preventDefault();
                        showItem(item);
                    }).html(item[settings.dscAttr]);

                    liEl.click(function (e) {
                        e.preventDefault();
                        showItem(item);
                    }).append(aEl);
                    ulEl.append(liEl);
                });
            } else {
                liEl = $('<li>').addClass('no-results').html('No results');
                ulEl.append(liEl);
            }

            listEl.css({
                'left': inputEl.offset().left,
                'width': inputEl.outerWidth() - 16
            }).show();
        };

        // initial
        if (hiddenField && hiddenField.val()) {
            params = {};
            params[settings.idAttr] = hiddenField.val().split(', ').join(',');
            $.get(settings.url, params, lang.hitch(self, function (data) {
                _(data).each(lang.hitch(self, showItem));
            }), 'json');
        }

        settings.togglerField.click(function () {
            $('.optionsbox').find('input[type="radio"]').not($(this)).prop('checked', false).change();
        }).on('change', function () {
            $(this).parents('.optionsbox').find('.optionsbox-box, .optionsbox-input').toggle($(this).prop('checked'));
        });

        // handler
        self.find('.optionsbox-input').keyup(function () {
            var input = $(this),
                val = input.val();

            if (val.length >= 3) {
                params = {};
                params[settings.dscAttr] = val;

                input.addClass('loading');
                $.get(settings.url, params, lang.hitch(self, function (data) {
                    input.removeClass('loading');
                    showItemsList(data);
                }), 'json');
            } else if (val.length === 0) {
                listEl.hide();
            }
        });
    };
});
