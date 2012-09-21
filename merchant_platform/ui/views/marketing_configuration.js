define('marketing_configuration',
  ['wizard_bar', 'wizard_title', 'wizard_nav', 'wizard_options', 'jquery', 'backbone'],
  function (WizardBar, WizardTitle, WizardNav, WizardOptions) {

    var MarketingConfiguration = Backbone.View.extend({

      template: null,

      wizardOptions: null,

      initialize: function () {
        this.template = _.template($('#templates .marketing_configuration').html());
        this.render();
      },

      render: function () {
        this.$el
          .html(this.template())
          .addClass('marketing_configuration');
        new WizardBar({
          el: this.$el.find('.wizard_bar'),
          step: 1
        });
        new WizardTitle({
          el: this.$el.find('.wizard_title'),
          heading: 'Marketing Configuration',
          paragraph: 'Here you\'ll configurate the marketplace, custom site and point of sale.'
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
              heading: 'Marketplace',
              paragraph: 'The Monthlys marketplace gives you access to thousands of local customers and gives your business tons of exposure. We do not recommend disabling this feature.',
              image: 'images/wizard_options_default_icon.png',
              value: 1,
              tooltip: 'Marketplace'
            },
            {
              heading: 'Custom Site',
              paragraph: 'Design and configure your own custom subscription site. Use this platform for your private marketing channels.',
              image: 'images/wizard_options_default_icon.png',
              value: 2,
              tooltip: 'Custom Site'
            },
            {
              heading: 'Point of Sale',
              paragraph: 'Monthlys will deliver to your location, point of sale stationary and collateral for your customers. Monthlys is quickly becoming a recognizable local service, so having Point of Sale enabled is highly recommended. There is no charge for point of sale stationary or design.',
              image: 'images/wizard_options_default_icon.png',
              value: 3,
              tooltip: 'Point of sale'
            }
          ]
        });
      },

      onBack: function () {
        window.router.navigate('/welcome', true);
      },

      onNext: function () {
        if (this.validate()) {
          window.router.navigate('/service-area', true);
        }
      },

      validate: function () {
        return true;
      }

    });

    return MarketingConfiguration;

  }
);