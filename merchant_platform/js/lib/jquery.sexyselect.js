define(['jquery'], function ($) {

  /**
   * Default option values.
   */
  var defaults= {
    select: true,
    select_multiple: true,
    checkbox: true,
    radio: true,
    file: true
  };

  $.fn.sexyForm = function (options) {
    // Override default with user-defined options.
    defaults = $.extend(defaults, options || {});
    // Pimp the :input elements inside the selection.
    return $(this).each(function (index, object) {
      sexyForm($(object));
    });
  }

  $.fn.sexySelect = function () {
    return $(this).each(function (index, object) {
      createSelect($(object));
    }); 
  }

  /**
   * Creates custom instances of the :input elements inside
   * form.
   * @param   form    the form to customize.
   */
  function sexyForm(form) {
    var options = defaults;
    form.find(':input').each(function (index, object) {
      if (object.tagName === 'SELECT') {
        if (!!object.multiple && !!defaults.select_multiple) {
          createMultipleSelect(object);
        }
        else if (!!defaults.select) {
          createSelect(object);
        }
      }
      else if (object.tagName === 'INPUT') {
        if (object.type === 'checkbox' && !!defaults.checkbox) {
          createCheckbox(object);
        }
        else if (object.type === 'radio' && !!defaults.radio) {
          createRadio(object);
        }
        else if (object.type === 'file' && !!defaults.file) {
          createFile(object);
        }
      }
    });
  }

  /***** INPUT TYPES *****/

  /**
   * Select input constructor.
   */
  function createSelect(select) {
    var list = $('<ul />')
      , listItem
      , display = $('<p />')
      , container = $('<a />')
      , substitute = $('<input />')
      , select = $(select);

    // Build select substitute.
    substitute
      .val(select.val())
      .attr({
        'name'     : select.attr('name'),
        'type'     : 'hidden'
      });

    // Build list.
    list
      .addClass('sexyform-select-list')
      .hide();
    select.find('option').each(function (index, object) {
      object = $(object);
      listItem = $('<li />');
      listItem
        .addClass(object.is(':selected') ? 'selected' : '')
        .html(object.html())
        .data('value', object.val())
        .appendTo(list);
    });

    // Build display.
    display
      .addClass('sexyform-select-display')
      .html(select.find('option:selected').html());

    // Build container.
    container
      .addClass('sexyform-select')
      .insertBefore(select)
      .append(list, display, substitute)
      .attr({
        'tabindex' : select.attr('tabindex')
      });
    
    // Remove select so the new custom select
    // can take over.
    select
      .remove();

    // Apply handlers to the elements of the
    // custom select.
    container
      .bind({
        keydown: function (event) {
          // Space-bar
          if (event.keyCode === 32) {
            toggleList();
            // Prevent the page from scrolling down.
            return false;
          }
          // Enter key
          else if (event.keyCode === 13) {
            hideList();
            // If we dont return false here, the enter key
            // gets to the form and submits.
            return false;
          }
          // Tab
          else if (event.keyCode === 9) {
            hideList();
          }
          // Down-arrow key or left-arrow key
          else if (event.keyCode === 40 || event.keyCode === 37) {
            selectNext();
            return false;
          }
          // Up-arrow key or right-arrow key
          else if (event.keyCode === 38 || event.keyCode === 39) {
            selectPrev();
            return false;
          }
        },
        focus: function () {
          container.addClass('focused')
        },
        blur: function () {
          container.removeClass('focused'); 
        }
      });
    list
      .bind({
        click: function (event) {
          var target = $(event.target);
          setValue(target);
          substitute.focus();
          hideList();
        }
      });
    display
      .bind({
        click: function () {
          showList();
          substitute.focus();
        }
      });
    $(document.body)
      .bind({
        click: function (event) {
          // If the user clicked anywhere outside the 
          // custom select's container, the list is hidden.
          if (!$.contains(container.get(0), event.target)) {
            hideList();
          }
        }
      })

    /***** HELPER METHODS *****/
    function setValue(listItem) {
      // Trigger only if the target is one of the
      // items in the list.
      if ($.contains(list.get(0), listItem.get(0))) {
        list.find('li').removeClass('selected');
        listItem.addClass('selected');
        display.html(listItem.html());
        substitute
          .val(listItem.data('value'))
          .change();
      }
    }

    function selectNext() {
      var selected = list.find('li.selected');
      if (selected.next().length !== 0) {
        setValue(selected.next());
      }
    }

    function selectPrev() {
      var selected = list.find('li.selected');
      if (selected.prev().length !== 0) {
        setValue(selected.prev());
      }
    }

    function toggleList() {
      list.toggle();
    }

    function showList() {
      list.show();
    }

    function hideList() {
      list.hide();
    }
  }

  function createMultipleSelect(select) {}
  function createCheckbox(input) {}
  function createRadio(input) {}
  function createFile(input) {}

});
