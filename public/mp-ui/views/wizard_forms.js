define('wizard_forms', ['jquery', 'backbone'], function () {

  var WizardForms = {};

  WizardForms.Field = Backbone.View.extend({

    fieldParent: null,

    focused: false,

    validated: false,

    initialize: function () {
      this.render();
    },

    render: function () {
      this.fieldParent = this.$el.parents('.input');
      this.fieldParent
        .css({ opacity: 0.5 })
        .bind({
          mouseover: $.proxy(this.onMouseover, this),
          mouseout: $.proxy(this.onMouseout, this)
        });
      this.$el
        .bind({
          focus: $.proxy(this.onFocus, this),
          blur: $.proxy(this.onBlur, this),
          keyup: $.proxy(this.onKeyup, this)
        });
    },

    getKey: function () {
      return this.$el.attr('name');
    },

    getValue: function () {
      return this.$el.val();
    },

    validate: function () {
      var validation = this.options.validation;
      this.validated = true;
      if (typeof validation === 'function' && !validation(this.getValue())) {
        this.fieldParent.addClass('error');
        return false;
      }
      this.fieldParent.removeClass('error');
      return true;
    },

    onFocus: function () {
      this.focused = true;
      this.fieldParent
        .addClass('focused')
        .stop().animate({ opacity: 1 }, { duration: 200 });
    },

    onBlur: function () {
      this.focused = false;
      this.fieldParent
        .removeClass('focused')
        .stop().animate({ opacity: 0.5 });
    },

    onMouseover: function () {
      if (this.focused === false) {
        this.fieldParent.stop().animate({ opacity: 1 }, { duration: 200 });
      }
    },

    onMouseout: function () {
      if (this.focused === false) {
        this.fieldParent.stop().animate({ opacity: 0.5 });
      }
    },

    onKeyup: function () {
      if (this.validated === true) {
        this.validate();
      }
    }

  });

  WizardForms.SelectField = WizardForms.Field.extend({

    selectionDisplay: null,

    optionList: null,

    optionListOpen: false,

    initialize: function () {
      this.render();
      this.buildSelect();
    },

    buildSelect: function () {
      this.buildHandle();
      this.buildSelectedOption();
      this.buildOptionList();
      this.reflectSelection();
      this.$el.bind({
        change: $.proxy(this.reflectSelection, this),
        focus: $.proxy(this.showOptionList, this),
        blur: $.proxy(this.hideOptionList, this)
      });
    },

    buildHandle: function () {
      $('<a />')
        .attr('href', '#')
        .addClass('handle')
        .prependTo(this.fieldParent)
        .bind({
          mouseover: $.proxy(this.onMouseover, this),
          mouseout: $.proxy(this.onMouseout, this),
          click: $.proxy(this.onClickHandle, this)
        })
    },

    buildSelectedOption: function () {
      this.selectionDisplay = $('<p />')
        .addClass('selected')
        .prependTo(this.fieldParent);
    },

    buildOptionList: function () {
      var lis = [],
          options = this.$el.find('option'),
          option;
      options.each(function (i, obj) {
        option = $(obj);
        lis.push('<li data-value="'+ option.val() +'"><a href="#">' + 
          option.html() + '</a></li>');
      });
      this.optionList = $('<ul />')
        .addClass('wizard_forms_select_options')
        .appendTo(document.body)
        .bind('click', $.proxy(this.onOptionListClick, this))
        .html(lis.join(''));
    },

    reflectSelection: function () {
      var val = this.$el.val();
      this.selectionDisplay.html(val);
      this.optionList
        .find('li')
        .removeClass('selected')
        .filter(function () {
          return $(this).attr('data-value') === val;
        })
        .addClass('selected');
    },

    showOptionList: function () {
      if (!this.optionListOpen) {
        this.optionListOpen = true;
        var offset = this.selectionDisplay.offset();
        this.optionList
          .css({
            left: offset.left,
            top: offset.top + this.selectionDisplay.height() - 1,
            width: this.fieldParent.outerWidth()
          })
          .show(); 
      }
    },

    hideOptionList: function () {
      if (this.optionListOpen) {
        var $this = this;
        setTimeout(function () {
          $this.optionListOpen = false;
          $this.optionList.hide();
        }, 100);
      }
    },

    onOptionListClick: function (e) {
      this.$el.val($(e.target).parent().attr('data-value'));
      this.reflectSelection();
      return false;
    },

    onClickHandle: function () {
      this.$el.focus();
      return false;
    },

    onKeyup: function () {
      this.reflectSelection();
    }

  });

  WizardForms.TokenizerField = WizardForms.Field.extend({

    source: null,

    selection: null,

    containerElement: null,

    tokenList: null,

    suggestionList: null,

    initialize: function () {
      // Save source into instance
      this.source = this.options.source;
      this.selection = [];
      this.render();
      this.buildTokenList();
      this.buildSuggestionList();
      this.buildTokeinzer();
    },

    buildTokenList: function () {
      // Build list of tokens
      this.tokenList = $('<ul />');
    },

    buildSuggestionList: function () {
      // Build list of suggestions
      this.suggestionList = $('<ul />');
      this.suggestionList
        .addClass('wizard_forms_tokenizer_suggestion_list');
    },

    buildTokeinzer: function () {
      // Add class to container
      this.fieldParent
        .addClass('wizard_tokenizer')
        .bind({ click: $.proxy(this.focusInput, this) });
      // Put list of tokens into container
      this.tokenList.insertBefore(this.$el);
      this.$el.bind({
        blur: $.proxy(function () {
          setTimeout($.proxy(this.hideSuggestions, this), 100);
        }, this)
      });
    },

    onSuggestionClick: function (e) {
      this.select($(e.target).parent());
      this.addSelected();
      return false;
    },

    onKeyup: function (e) {
      var keyCode = e.keyCode;
      // Arrow-down key
      if (keyCode == 40) {
        this.selectNext();
      }
      // Arrow-up key
      else if (keyCode === 38) {
        this.selectPrevious();
      }
      // Enter key
      else if (keyCode === 13) {
        this.addSelected();
      }
      // Escape key
      else if (keyCode === 27) {
        this.hideSuggestions();
      }
      // Any other key (typing lookup...)
      else {
        this.fetchSuggestions();
      }
    },

    onItemRemove: function (item) {
      var newSelection = [];
      $(this.selection).each(function (i, obj) {
        if (obj !== item.getValue()) {
          newSelection.push(obj);
        }
      });
      this.selection = newSelection;
      this.reflectSelection();
      this.focusInput();
    },

    focusInput: function () {
      this.$el.focus();
    },

    /**
     * TODO: Mix this with an ajax call
     */
    fetchSuggestions: function () {
      var selection = this.selection,
          results = [],
          val = this.$el.val();
      if (val !== '') {
        $(this.source).each(function (i, obj) {
          if (obj.toLowerCase().indexOf(val.toLowerCase()) === 0) {
            results.push(obj);
          }
        });
        this.showSuggestions(results);
      }
      else {
        this.hideSuggestions();
      }
    },

    showSuggestions: function (suggestions) {
      var offset = this.fieldParent.offset(),
          suggestionList = this.suggestionList,
          selection = this.selection;

      // Show and place list under input
      suggestionList
        .empty()
        .show()
        .css({
          left: offset.left,
          top: offset.top + this.fieldParent.height(),
          width: this.fieldParent.width()
        })
        .appendTo(document.body);

      // Populate suggestion list
      $(suggestions).each(function (i, obj) {
        if (selection.indexOf(obj) === -1) {
          $('<li>')
            .attr('data-value', obj)
            .html('<a href="#">' + obj + '</a>')
            .appendTo(suggestionList); 
        }
      });

      // Bind handler
      suggestionList.find('a')
        .bind('click', $.proxy(this.onSuggestionClick, this));
      this.selectFirst();
    },

    hideSuggestions: function () {
      this.suggestionList.remove();
    },

    select: function (li) {
      this.suggestionList
        .find('li.selected').removeClass('selected');
      li.addClass('selected');
    },

    selectFirst: function () {
      this.suggestionList.find('li:first').addClass('selected');
    },

    selectPrevious: function () {
      var selected = this.suggestionList.find('li.selected');
      if (selected.prev().length !== 0) {
        this.select(selected.prev());
      }
    },

    selectNext: function () {
      var selected = this.suggestionList.find('li.selected');
      if (selected.next().length !== 0) {
        this.select(selected.next());
      }
    },

    addSelected: function () {
      var selected = this.suggestionList.find('li.selected');
      if (selected.length === 1) {
        selected.removeClass('selected');
        this.selection.push(selected.attr('data-value'));
        this.reflectSelection();
        this.hideSuggestions();
        this.$el.val('');
        this.focusInput();
      }
    },

    reflectSelection: function () {
      var tokenList = this.tokenList,
          tokenItem,
          onItemRemove = $.proxy(this.onItemRemove, this);
      tokenList.empty();
      $(this.selection).each(function (i, obj) {
        tokenItem = new TokenizerFieldItem({
          el: $('<li />'),
          title: obj,
          onRemove: onItemRemove
        });
        tokenItem.$el
          .appendTo(tokenList);
      });
    }

  });

  /**
   * An item in a list of selected items in the tokenizer.
   */
  var TokenizerFieldItem = Backbone.View.extend({

    events: {
      'click a': 'onClick'
    },

    initialize: function () {
      this.render();
    },

    render: function () {
      var template = _.template($('#templates .wizard_form_tokenizer_item').html());
      this.$el.html(template({
        title: this.options.title
      }));
    },

    onClick: function () {
      this.options.onRemove(this);
      return false;
    },

    getValue: function () {
      return this.options.title;
    }

  });

  WizardForms.ImageField = WizardForms.Field.extend({

  });

  return WizardForms;

});