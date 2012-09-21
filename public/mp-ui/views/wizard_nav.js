define('wizard_nav', ['jquery', 'backbone'], function () {

  var WizardNavigation = Backbone.View.extend({

    template: null,

    events: {
      'click .back': 'onBack',
      'click .next': 'onNext'
    },

    initialize: function () {
      this.template = _.template($('#templates .wizard_nav').html());
      this.render();
    },

    render: function () {
      this.$el.html(this.template());
      if (this.options.showBack === false) {
        this.$el.find('.back').remove();
      }
      if (this.options.showNext === false) {
        this.$el.find('.next').remove();
      }
    },

    onBack: function () {
      this.options.onBack();
      return false;
    },

    onNext: function () {
      this.options.onNext();
      return false;
    }

  });

  return WizardNavigation;

});