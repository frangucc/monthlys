/*jslint indent: 2*/
/*global define*/
define(['jquery', 'app/messages'], function ($) {
  'use strict';

  function getSuccessHandler(form) {
    return function (response) {
      if (response.status === 'error') {
        form.displayResourceErrors({
          errors: { newsletter_subscriber: response.errors }
        });
      } else if (response.status === 'success') {
        form.find('.error-message').remove();
        form
          .find('.messages')
          .displayMessage('success', response.messages);
      }
    };
  }

  function init(options) {
    var form = options.form;
    // TODO Don't harcode URL, manage with Routes module
    form.submit(function (e) {
      e.preventDefault();
      $.post(form.attr('action'),
             form.serialize(),
             getSuccessHandler(form));
    });
  }

  return { init: init };
});
