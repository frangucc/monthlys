define('wizard_options', ['jquery', 'jquery.colorbox', 'backbone'], function () {

  var WizardOptions = Backbone.View.extend({

    template: null,

    optionViews: null,

    initialize: function () {
      this.optionViews = [];
      this.template = _.template($('#templates .wizard_options').html());
      this.render();
    },

    render: function () {
      var options = this.options.options,
          optionContainer,
          onSelectOption = $.proxy(this.onSelectOption, this);
      this.$el.html(this.template());
      optionContainer = this.$el.find('.options');
      for (var i = 0, max = options.length; i < max; i++) {
        this.optionViews.push(new WizardOption({
          container: optionContainer,
          onSelectOption: onSelectOption,
          option: options[i]
        }));
      }
      // Even size
      this.evenHeights();
      this.evenWidths();
      // Mark first and last
      this.$el.find('.option:first').addClass('first');
      this.$el.find('.option:last').addClass('last');
      // Select first
      this.onSelectOption(this.optionViews[0]);
    },

    evenHeights: function () {
      var interval = null,
          el = this.$el;
      interval = setInterval(function () {
        // Get higher option
        var higher = 0;
        el.find('.option .frame')
          .each(function (i, obj) {
            obj = $(obj);
            if (obj.height() > higher) {
              higher= obj.height();
            }
          });
        // Set higher option's height to all options
        el.find('.option .frame')
          .css({
            height: higher + 'px'
          });
      }, 100);
    },

    evenWidths: function () {
      this.$el.find('.option').css({
        width: (Math.floor(100 / this.optionViews.length) + '%')
      });
    },

    onSelectOption: function (selectedOption) {
      var options = this.optionViews;
      for (var i = 0, max = options.length; i < max; i++) {
        options[i].setSeleted(false);
      }
      selectedOption.setSeleted(true);
    },

    getSelected: function () {
      var options = this.optionViews;
      for (var i = 0, top = options.length; i < top; i++) {
        if (options[i].getSelected()) {
          return options[i].getValue();
        }
      }
    }

  });

  var WizardOption = Backbone.View.extend({

    template: null,

    events: {
      'click': 'onSelect',
      'click a.readmore': 'onReadmoreClick',
      'click a.checkbox': 'onCheckboxClick'
    },

    initialize: function () {
      this.template = _.template($('#templates .wizard_options_item').html());
      this.render();
    },

    render: function () {
      var option = this.options.option;
      this.$el
        .html(this.template({
          heading: option.heading,
          paragraph: option.paragraph,
          image: option.image,
          value: option.value
        }))
        .addClass('option')
        .appendTo(this.options.container);
      if (typeof option.readmore !== 'undefined') {
        this.$el.find('.readmore').css('display', 'block');
      }
      if (typeof option.tooltip !== 'undefined') {
        this.$el.find('.tooltip')
          .css('display', 'block')
          .attr('title', option.tooltip)
      }
    },

    onSelect: function () {
      this.options.onSelectOption(this);
    },

    setSeleted: function (selected) {
      selected ? this.$el.removeClass('deselected') : this.$el.addClass('deselected');
    },

    getSelected: function () {
      return !this.$el.is('.deselected');
    },

    getValue: function () {
      return this.options.option.value;
    },

    onReadmoreClick: function () {
      $.colorbox({
        inline: true,
        href: this.options.option.readmore,
        width: 700,
        height: 625,
        fixed: true,
        scrolling: false,
        opacity: 0.8
      });
      return false;
    },

    onCheckboxClick: function () {
      this.onSelect();
      return false;
    }

  });

  return WizardOptions;

});