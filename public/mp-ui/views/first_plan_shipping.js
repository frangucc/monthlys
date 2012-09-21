define('first_plan_shipping', 
  ['wizard_nav', 'wizard_title', 'jquery', 'backbone'], 
  function (WizardNav, WizardTitle) {

    var FirstPlanShipping = Backbone.View.extend({

      initialize: function () {
        this.template = _.template($('#templates .first_plan_shipping').html());
        this.render();
      },

      render: function () {
        this.$el.html(this.template());
        new WizardNav({
          el: this.$el.find('.wizard_nav'),
          onBack: function () {

          },
          onNext: function () {

          }
        });
        new WizardTitle({
          el: this.$el.find('.wizard_title'),
          heading: 'Shipping & Billing Info',
          paragraph: 'Here you can add differents shipping and billing options for you customers choose the one it fits best.'
        });
        this.$el
          .find('.billing_options .option a')
          .click(this.onBillingCheckboxClick);
        this.$el
          .find('.shipping_options .option a')  
          .click(this.onShippingCheckboxClick);
      },

      onBillingCheckboxClick: function () {
        $(this).parents('.option')
          .toggleClass('checked');
        return false;
      },

      onShippingCheckboxClick: function () {
        var $this = $(this);
        $this.parents('.shipping_options')
          .find('.option')
          .removeClass('checked');
        $this.parents('.option')
          .addClass('checked');
        return false;
      }

    });

    return FirstPlanShipping;

  }
);