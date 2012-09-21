define(['jquery'], function ($) {
  "use strict";

  $.fn.imageWidget = function (hooks) {
    return $(this).each(function (index, input) {
      if ($(this).parent('.imagewidget-container').size() > 0) {
          return;
      }
      createImageWidget($(input));
    });
  };

  function createImageWidget(input) {
    var container = $('<div />'),
        handle, display;

    handle = createHandle(container);
    display = createDisplay(container);

    applyHandlers(input, container, handle, display);

    input
      .addClass('imagewidget-input');

    container
      .addClass('imagewidget-container')
      .insertBefore(input)
      .append(input, handle, display);

    reflectSelection({
      input: input,
      display: display
    });
  }

  function createHandle() {
    var icon = $('<span />').addClass('imagewidget-icon'),
        handle = $('<a />');

    handle
      .html('Choose a file...')
      .addClass('imagewidget-handle')
      .prepend(icon);
    return handle;
  }

  function createDisplay() {
    return $('<p />').addClass('imagewidget-display');
  }

  function applyHandlers(input, container, handle, display) {
    handle.bind({
      'click': function () {
        input.click();
      }
    });
    input.bind({
      'change': function () {
        reflectSelection({
          input: input,
          display: display
        });
      }
    })
  }

  function reflectSelection(command) {
    command.display.html(command.input.val());
  }

});
