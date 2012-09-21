define('welcome',
  ['wizard_bar', 'wizard_nav', 'wizard_title', 'wizard_options', 'jquery', 'backbone'],
  function (WizardBar, WizardNav, WizardTitle, WizardOptions) {

    var Welcome = Backbone.View.extend({

      wizardOptions: null,

      initialize: function () {
        this.template = _.template($('#templates .welcome').html());
        this.render();
      },

      render: function () {
        this.$el
          .html(this.template())
          .addClass('welcome');
        new WizardBar({
          el: this.$el.find('.wizard_bar'),
          step: 1
        });
        new WizardTitle({
          el: this.$el.find('.wizard_title'),
          heading: 'Welcome Federico!',
          paragraph: 'Here you will setup your account, plans and storefront. Also you can preview it at anytime.'
        });
        new WizardNav({
          el: this.$el.find('.wizard_nav'),
          showBack: false,
          onNext: $.proxy(this.onNext, this)
        });
        this.wizardOptions = new WizardOptions({
          el: this.$el.find('.wizard_options'),
          options: [
            {
              heading: 'Setup Asssitance',
              paragraph: 'Select this option if you would like a member of the Monthlys merchandising team to setup your account.',
              image: 'images/wizard_options_default_icon.png',
              value: 1
            },
            {
              heading: 'No Assistance',
              paragraph: 'Select this option if you would like to setup your account. You may ask for assistance later.',
              image: 'images/wizard_options_default_icon.png',
              value: 2
            }
          ]
        });
      },

      onNext: function () {
        if (this.getSetupSelection()) {
          window.router.navigate('/setup', true);
        }
        else {
          window.router.navigate('/marketing-configuration', true);
        }
      },

      getSetupSelection: function () {
        return this.wizardOptions.getSelected() === 1;
      }

    });

    return Welcome;

  }
);