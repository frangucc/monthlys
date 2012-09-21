define(['jquery'], function ($) {

  function messagesHtml(messages) {
    var content = []
      , i;
    for (i = 0; i < messages.length; i++) {
      if (messages[i] !== '') {
        content.push('<p>', messages[i], '</p>');
      }
    }
    return content.join('');
  }

  $.fn.displayMessage = function(type, messages) {
    var content
    , innerContent = '';

    if (typeof messages === 'string') {
      innerContent += messagesHtml([messages]);
    }
    else {
      innerContent += messagesHtml(messages);
    }
    if (innerContent !== '') {
      content = ['<div class="message flash-' + type + '">', innerContent, '</div>'].join('');
      this
        .show()
        .empty()
        .html(content);
    }
    else {
      this.hide();
    }
  };

  function errorHtml(fieldErrors) {
    var errors = '';
    for (i = 0; i < fieldErrors.length; i++) {
      errors += '<p>' + fieldErrors[i] + '</p>';
    }
    return '<div class="error-message">' + errors + '</div>';
  }

  $.fn.displayResourceErrors = function (options) {
    var fieldName, settings;

    settings = $.extend( {
      form: $(this)
    }, options);

    settings.form.find('.error-message').remove();

    $.each(options.errors, function (ns, resourceErrors) {
      $.each(resourceErrors, function (field, fieldErrors) {
        fieldName = ns + "[" + field + "]";
        settings.form
          .find('[name="' + fieldName +'"]')
            .parent().addClass('error') // target <p> tag above
            .before(errorHtml(fieldErrors));
      })
    });
  };

});
