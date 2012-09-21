define('setup', ['wizard_bar', 'wizard_title', 'wizard_nav', 'jquery', 'backbone'], function (WizardBar, WizardTitle, WizardNav) {

  var Setup = Backbone.View.extend({

    template: null,

    initialize: function () {
      this.template = _.template($('#templates .setup').html());
      this.render();
    },

    render: function () {
      this.$el
        .html(this.template())
        .addClass('setup');
      new WizardBar({
        el: this.$el.find('.wizard_bar'),
        step: 1
      });
      new WizardTitle({
        el: this.$el.find('.wizard_title'),
        heading: 'Setup Assistance',
        paragraph: 'Thanks! We\'ll let you know when your setup is ready. Please download the PDF with a list of all your assets you should prepare for us.'
      });
      new WizardNav({
        el: this.$el.find('.wizard_nav'),
        showNext: false,
        onBack: function () {
          window.router.navigate('/welcome', true);
        }
      });
    }

  });

  return Setup;

});