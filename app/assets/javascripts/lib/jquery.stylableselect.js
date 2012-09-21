define(['jquery'], function ($) {

  $.fn.stylableSelect = function() {
    $(this).each(function () {
      if (this.multiple) {
        new StylableMultipleSelect(this);
      }
      else {
        new StylableSimpleSelect(this);
      }
    });
  };

  /***************************************************/
  /***************************************************/
  /****************** SIMPLE SELECT ******************/
  /***************************************************/
  /***************************************************/

  /****************** CONSTRUCTOR ******************/

  function StylableSimpleSelect(select) {
    var option, wrapper, display, handle, list, listitem;

    // jquery select
    select = $(select);

    // create dom elements
    wrapper = $('<a href="#" class="stylableselect" tabindex="' + select.attr('tabindex') + '"></a>');
    display = $('<div class="display"></div>');
    handle  = $('<div class="handle" href="#">+</div>'); // TODO: add option for this
    list    = $('<div class="list"></div>');
    select.attr('tabindex', '-1');

    // create options
    select.find('option').each(function () {
      option = $(this);

      listitem = $('<div class="listitem" data-value="' + option.val() + '"></div>');
      listitem.append('<div class="optionvalue">' + option.html() + '</div>');
      listitem.appendTo(list);

      $.each(option.data(), function (key, value) {
        listitem.append('<div class="optiondata ' + key + '">' + value + '</div>');
      });
    });

    // append dom elements
    select.before(wrapper);
    wrapper.append(select, display, handle, list);

    // apply event handlers
    wrapper.bind({
      click : $.proxy(this.onClick, this),
      focus : $.proxy(this.onFocus, this),
      blur  : $.proxy(this.onBlur, this),
      keyup : $.proxy(this.onKeydown, this)
    });

    // attach to object
    this.select = select;
    this.wrapper = wrapper;
    this.display = display;
    this.handle = handle;
    this.list = list;

    // initial state
    list.hide();
    this.checkItem(list.find('.listitem').filter(function () {
      return $(this).data('value').toString() === select.find('option:selected').val();
    }));
  };

  /****************** EVENT HANDLERS ******************/

  /*
   * Handles click events on the wrapper and
   * delegates depending on the target element.
   */
  StylableSimpleSelect.prototype.onClick = function(event) {
    var target = $(event.target);
    // click on handle or display shows/hides the list.
    if (target.is('.stylableselect') || target.is('.display') || target.is('.handle')) {
      this.toggleList();
    }
    // click on option text changes the value.
    else if (target.is('.optionvalue') || target.is('.optiondata')) {
      this.checkItem(target.parent());
      this.list.hide();
    }
    // click on the list changes the value.
    else if (target.is('.listitem')) {
      this.checkItem(target);
      this.list.hide();
    }
    return false;
  };

  StylableSimpleSelect.prototype.onFocus = function() {
    this.wrapper.addClass('focused');
    $(window).bind('keydown.disable', function (event) {
      if ([32, 37, 38, 39, 40].indexOf(event.keyCode) >= 0) {
        return false;
      }
    })
  };

  StylableSimpleSelect.prototype.onBlur = function() {
    this.wrapper.removeClass('focused');
    this.list.hide();
    $(window).unbind('keydown.disable');
  };

  StylableSimpleSelect.prototype.onKeydown = function(event) {
    if (event.keyCode === 39 || event.keyCode === 40) {
      this.selectNext();
    }
    else if (event.keyCode === 37 || event.keyCode === 38) {
      this.selectPrevious();
    }
    else if (event.keyCode === 32) {
      this.toggleList();
    }
  };

  /****************** SELECT METHODS ******************/

  StylableSimpleSelect.prototype.toggleList = function() {
    if (this.list.is(':visible')) {
      this.list.hide();
    }
    else {
      this.list.show();
    }
  };

  StylableSimpleSelect.prototype.checkItem = function(listitem) {
    var value = listitem.data('value')
      , label = listitem.find('.optionvalue').html();

    this.list.find('.listitem').removeClass('selected');
    listitem.addClass('selected');

    this.select.val(value).change();
    this.display.html(label);
  };

  StylableSimpleSelect.prototype.selectNext = function() {
    var next = this.list.find('.listitem.selected').next();
    if (next.length !== 0) {
      this.checkItem(next);
    }
  };

  StylableSimpleSelect.prototype.selectPrevious = function() {
    var prev = this.list.find('.listitem.selected').prev();
    if (prev.length !== 0) {
      this.checkItem(prev);
    }
  };

  /***************************************************/
  /***************************************************/
  /****************** MULTIPLE SELECT ******************/
  /***************************************************/
  /***************************************************/

  function StylableMultipleSelect(select) {
    var option, wrapper, display, handle, list, listitem, apply;

    // jquery select
    select = $(select);

    // create dom elements
    wrapper = $('<a href="#" class="stylableselect multiple" tabindex="' + select.attr('tabindex') + '"></a>');
    display = $('<div class="display"></div>');
    handle  = $('<div class="handle" href="#">+</div>'); // TODO: add option for this
    list    = $('<div class="list"></div>');
    apply   = $('<div class="apply">Apply</div>');
    select.attr('tabindex', '-1');

    // create options
    select.find('option').each(function () {
      option = $(this);

      listitem = $('<div class="listitem" data-value="' + option.val() + '"></div>');
      listitem.append('<input type="checkbox" name="stylable-' + select.attr('name') + '" />');
      listitem.append('<div class="optionvalue">' + option.html() + '</div>');
      listitem.appendTo(list);

      $.each(option.data(), function (key, value) {
        listitem.append('<div class="optiondata ' + key + '">' + value + '</div>');
      });
    });

    // append dom elements
    select.before(wrapper);
    list.append(apply);
    wrapper.append(select, display, handle, list);

    // apply event handlers
    wrapper.bind({
      click : $.proxy(this.onClick, this),
      focus : $.proxy(this.onFocus, this),
      blur  : $.proxy(this.onBlur, this),
      keyup : $.proxy(this.onKeydown, this)
    });

    // attach to object
    this.select = select;
    this.wrapper = wrapper;
    this.display = display;
    this.handle = handle;
    this.list = list;
    this.apply = apply;

    // initial state
    list.hide();
    this.updateDisplay([]);
    this.checkActive();
  };

  /****************** EVENT HANDLERS ******************/

  /*
   * Handles click events on the wrapper and
   * delegates depending on the target element.
   */
  StylableMultipleSelect.prototype.onClick = function(event) {
    var target = $(event.target);
    // click on handle or display shows/hides the list.
    if (target.is('.stylableselect') || target.is('.display') || target.is('.handle')) {
      this.toggleList();
    }
    // click on option text changes the value.
    else if (target.is('.optionvalue') || target.is('.optiondata')) {
      this.checkItem(target.parent());
    }
    // click on the list changes the value.
    else if (target.is('.listitem')) {
      this.checkItem(target);
    }
    // click on the apply button applies the changes
    else if (target.is('.apply')) {
      this.activateChecked();
    }
    return false;
  };

  StylableMultipleSelect.prototype.onFocus = function() {
    this.wrapper.addClass('focused');
    $(window).bind('keydown.disable', function (event) {
      if ([32, 37, 38, 39, 40].indexOf(event.keyCode) >= 0) {
        return false;
      }
    })
  };

  StylableMultipleSelect.prototype.onBlur = function() {
    this.wrapper.removeClass('focused');
    this.list.hide();
    $(window).unbind('keydown.disable');
  };

  StylableMultipleSelect.prototype.onKeydown = function(event) {
    if (event.keyCode === 39 || event.keyCode === 40) {
      this.selectNext();
    }
    else if (event.keyCode === 37 || event.keyCode === 38) {
      this.selectPrevious();
    }
    else if (event.keyCode === 32) {
      if (this.list.is(':visible')) {
        this.checkSelected();
      }
      else {
        this.showList();
      }
    }
    else if (event.keyCode === 13) {
      this.activateChecked();
    }
  };

  /****************** SELECT METHODS ******************/

  StylableMultipleSelect.prototype.updateDisplay = function(labels) {
    if (labels.length === 0) {
      this.display.html('Choose...').addClass('empty');
    }
    else {
      this.display.html(labels.join(', ')).removeClass('empty');
    }
  }

  StylableMultipleSelect.prototype.showList = function() {
    this.checkActive();
    this.selectItem(this.list.find('.listitem:eq(0)'));
    this.list.show();
  };

  StylableMultipleSelect.prototype.toggleList = function() {
    if (this.list.is(':visible')) {
      this.list.hide();
    }
    else {
      this.showList();
    }
  };

  StylableMultipleSelect.prototype.activateChecked = function() {
    var values = []
      , labels = [];
    this.list.find('.listitem')
      .filter(function () {
        return $(this).find(':checkbox').is(':checked');
      })
      .each(function () {
        var $this = $(this);
        values.push($this.data('value'));
        labels.push($this.find('.optionvalue').html());
      });
    this.select.val(values).change();
    this.list.hide();
    this.updateDisplay(labels);
  };

  StylableMultipleSelect.prototype.checkActive = function() {
    var stylableSelect = this
      , selectValue = stylableSelect.select.val()
      , listitem, labels = [];
    if (!!selectValue) {
      this.list.find('.listitem').each(function () {
        listitem = $(this);
        if (selectValue.indexOf(listitem.data('value').toString()) >= 0) {
          listitem.find(':checkbox').attr('checked', true);
          listitem.addClass('active');
          labels.push(listitem.find('.optionvalue').html());
        }
        else {
          listitem.find(':checkbox').attr('checked', false);
          listitem.removeClass('active');
        }
      });
      this.updateDisplay(labels);
    }
  };

  StylableMultipleSelect.prototype.checkItem = function(listitem) {
    var checkbox = listitem.find(':checkbox');
    checkbox.attr('checked', !checkbox.is(':checked'));
    listitem.toggleClass('active', checkbox.is(':checked'));
    this.selectItem(listitem);
  };

  StylableMultipleSelect.prototype.checkSelected = function () {
    this.checkItem(this.list.find('.listitem.selected'));
  };

  StylableMultipleSelect.prototype.selectItem = function (listitem) {
    this.list.find('.listitem').removeClass('selected');
    listitem.addClass('selected');
  };

  StylableMultipleSelect.prototype.selectNext = function() {
    var next = this.list.find('.listitem.selected').next();
    if (next.length !== 0) {
      this.selectItem(next);
    }
  };

  StylableMultipleSelect.prototype.selectPrevious = function() {
    var prev = this.list.find('.listitem.selected').prev();
    if (prev.length !== 0) {
      this.selectItem(prev);
    }
  };

});
