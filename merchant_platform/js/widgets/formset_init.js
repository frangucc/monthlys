/*jslint indent: 4 */
/*global define*/

define(['jquery'], function ($) {
    'use strict';

    var methods = {
        incrementTotalForms: function (settings) {
            var e, i;
            e = $("#id_" + settings.formsetPrefix  + "-TOTAL_FORMS");
            i = parseInt(e.attr('value'), 10) + 1;
            e.attr('value', i);
            return i;
        },

        getTpl: function (settings) {
            var tplEl, re, tpl;

            tplEl = $('#' + settings.tplId);
            re = new RegExp('(' + settings.formsetPrefix + ')-EMPTYFORM(-)', 'g');
            return tplEl.clone().html().replace(re, "$1-" + settings.tplVarName + "$2");
        },

        addForm: function (settings) {
            var newCount, newEl;

            newCount = methods.incrementTotalForms(settings);
            newEl = $(settings.tpl.replace(new RegExp(settings.tplVarName, 'g'), newCount - 1));
            this.initForm(settings, newEl);

            $("#" + settings.formsetFormsId).append(newEl);
        },

        disableForm: function(formEl) {
            // TODO: For now we are just hiding the form but it'd be
            // nice to show it as disabled and allow the user to undo
            // the delete action.
            formEl.hide();
        },

        initForm: function(settings, form) {
            var deleteEl,
                deleteLinkEl,
                deleteCbxEl,
                self = this,
                formEl = $(form);

            formEl.find('.formset-field > .field.id').hide();

            if (settings.formsetCanDelete) {
                // Check the delete flag for this formset element and
                // all it's nested formsets.
                deleteEl = formEl.find('.formset-field > .field.DELETE');
                deleteCbxEl = deleteEl.find('input');

                if (deleteCbxEl.attr('checked')) {
                    this.disableForm(formEl);
                } else {
                    deleteEl.hide();
                    deleteLinkEl = $('<a class="remove" href="">Remove</a>').bind({
                        click: function(e) {
                            e.preventDefault();
                            deleteCbxEl.attr('checked', 'checked');
                            self.disableForm(formEl);
                        }
                    });

                    formEl.append(deleteLinkEl);
                }
            }
        },

        initInitialForms: function(settings) {
            var self = this;
            $('#' + settings.formsetFormsId + ' > .formset-wrapper').each(function() {
                self.initForm(settings, this);
            });
        }
    };

    $.fn.formsetInit = function (options) {
        var settings = options;
        settings.tplVarName = '{INDEX}';
        settings.tpl = methods.getTpl(settings);

        methods.initInitialForms(settings);

        $("#" + settings.addId).click(function(e) {
            var newForm;
            e.preventDefault();
            methods.addForm(settings);
        });

        return this;
    };
});
