define('wizard_bar', ['jquery', 'backbone'], function () {

  var WizardBar = Backbone.View.extend({

    template: null,

    initialize: function () {
      this.template = _.template($('#templates .wizard_bar').html());
      this.render();
    },

    render: function () {
      this.$el.html(this.template());
      this.setStep(this.options.step);
    },

    setStep: function (step) {
      this.$el.addClass('step' + step);
    }

  });

  return WizardBar;

});