define('service_area',
  ['wizard_bar', 'wizard_title', 'wizard_nav', 'wizard_options', 'jquery', 'backbone'], 
  function (WizardBar, WizardTitle, WizardNav, WizardOptions) {

    var ServiceArea = Backbone.View.extend({

      template: null,

      wizardOptions: null,

      initialize: function () {
        this.template = _.template($('#templates .service_area').html());
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
          heading: 'Service Area',
          paragraph: 'Select one of the following fields to define the area where you\'ll be able of deliver in the US.'
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
              heading: 'Zip Codes',
              paragraph: '',
              image: '',
              value: 1
            },
            {
              heading: 'Cities',
              paragraph: '',
              image: '',
              value: 2
            },
            {
              heading: 'States',
              paragraph: '',
              image: '',
              value: 3
            },
            {
              heading: 'Nationwide',
              paragraph: '',
              image: '',
              value: 4
            }
          ]
        });
      },

      onBack: function () {
        window.router.navigate('/marketing-configuration', true);
      },

      onNext: function () {
        window.router.navigate('/fullfilment-assistance', true);
      }

    });

    return ServiceArea;

  }
);