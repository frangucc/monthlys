define('fullfilment_assistance',
  ['wizard_bar', 'wizard_title', 'wizard_nav', 'wizard_options', 'jquery', 'backbone'], 
  function (WizardBar, WizardTitle, WizardNav, WizardOptions) {

  var FullfilmentAssitance = Backbone.View.extend({

    template: null,

    wizardOptions: null,

    initialize: function () {
      this.template = _.template($('#templates .fullfilment_assistance').html());
      this.render();
    },

    render: function () {
      this.$el.html(this.template());
      new WizardBar({
        el: this.$el.find('.wizard_bar'),
        step: 1
      });
      new WizardTitle({
        el: this.$el.find('.wizard_title'),
        heading: 'Fullfilment Assistance',
        paragraph: 'Select one of the following fields to define the area you\'ll be able to deliver'
      });
      new WizardNav({
        el: this.$el.find('.wizard_nav'),
        onBack: $.proxy(this.onBack, this),
        onNext: $.proxy(this.onNext, this)
      });
      this.wizardOptions = new WizardOptions({
        el: this.$el.find('.wizard_options'),
        options: [
          {
            heading: 'Fullfilment Assistance',
            paragraph: 'You do not currently ship or deliver locally and would like Monthlys to help you setup a shipping process at your location.',
            image: 'images/wizard_options_default_icon.png',
            value: 1,
            readmore: '.fullfilment_assistance_assistance_modal'
          },
          {
            heading: 'No Assistance',
            paragraph: 'You currently handle shipping. You will manage this process.',
            image: 'images/wizard_options_default_icon.png',
            value: 2,
            readmore: '.fullfilment_assistance_no_assistance_modal'
          }
        ]
      });
    },

    onBack: function () {
      window.router.navigate('/service-area', true);
    },

    onNext: function () {
      window.router.navigate('/first-plan', true);
    }

  });

  return FullfilmentAssitance;

});