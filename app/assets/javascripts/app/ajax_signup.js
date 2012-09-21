/*jslint indent: 2 */
/*global $,define,window*/

define([
  'jquery', 'lib/jquery.colorbox', 'app/in_field_label', 'app/messages'
], function ($) {
  'use strict';

  var config = {};

  function configureAction(options) {
    $.extend(config, options);
  }

  /**
   *
   */
  function cleanUpEvent() {
    if (typeof config.onReset === 'function') {
      config.onReset();
    }
    $.colorbox.close();
  }

  /**
   *
   */
  function loginSuccessfulAction() {
    if (typeof config.successCallback === 'function') {
      config.successCallback();
    } else {
      window.location.href = window.location.href;
    }
  }

  /**
   *
   */
  function onModalLoad() {
    var userForm = $('#new_user, #user_new');

    $('#cboxContent label').inFieldLabels();

    userForm.submit(function (event) {
      var url, params;

      event.preventDefault();

      url = userForm.attr('action') + '.json';
      params = $(this).serialize();
      $.post(url, params, function (content) {
        if (content.status === 'error') {
          $('#cboxContent .messages').displayMessage('flash-error', content.errors);

          // Resizing modal due to the DOM changes inside it
          $.colorbox.resize();
        } else if (content.status === 'success') {
          loginSuccessfulAction();
        } else { // Unexpected request
          window.location.href = window.location.href;
        }
      });
    });

    // Hiding close button in case enableClose is false
    if (config.enableClose === false) {
      $('#cboxClose').remove();
    }
  }

  function openModal(content) {
    var colorboxOptions = {
      html: content,
      width: 460,
      onComplete: onModalLoad,
      onCleanup: cleanUpEvent
    };

    if (config.enableClose === false) {
      colorboxOptions.overlayClose = false;
      colorboxOptions.escKey = false;
    }

    $.colorbox(colorboxOptions);
  }

  /**
   *
   */
  function signUpAction(successCallback) {
    if (typeof successCallback !== 'undefined') {
      config.successCallback = successCallback;
    }
    $.get('/registrations/form', function (content) {
      if (content.indexOf('user_new') === -1) { // Nasty lil fix. User is already signed in
        loginSuccessfulAction();
      } else {
        openModal(content);
      }
    });
  }

  /**
   *
   */
  function signInAction(successCallback) {
    if (typeof successCallback !== 'undefined') {
      config.successCallback = successCallback;
    }
    $.get('/sessions/form', function (content) {
      if (content.indexOf('user_new') === -1) { // Nasty lil fix. User is already signed in
        loginSuccessfulAction();
      } else {
        openModal(content);
      }
    });
  }

  // Sign in/up links event binding
  $('#sign-up-link').live('click', function (event) {
    event.preventDefault();
    signUpAction();
  });

  $('#sign-in-link').live('click', function (event) {
    event.preventDefault();
    signInAction();
  });

  return {
    configure: configureAction,
    signUp: signUpAction,
    signIn: signInAction
  };

});
