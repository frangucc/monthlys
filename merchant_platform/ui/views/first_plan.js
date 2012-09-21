define('first_plan',
  ['wizard_bar', 'first_plan_basic', 'first_plan_shipping', 'first_plan_addons', 'jquery', 'backbone'], 
  function (WizardBar, FirstPlanBasic, FirstPlanShipping, FirstPlanAddons) {

  var FirstPlan = Backbone.View.extend({

    template: null,

    basic: null,

    shipping: null,

    addons: null,

    initialize: function () {
      this.template = _.template($('#templates .first_plan').html());
      this.render();
    },

    render: function () {
      this.$el.html(this.template());

      new WizardBar({
        el: this.$el.find('.wizard_bar'),
        step: 2
      });

      this.basic = new FirstPlanBasic({
        el: this.$el.find('.first_plan_basic')
      });
      this.shipping = new FirstPlanShipping({
        el: this.$el.find('.first_plan_shipping')
      });
      this.addons = new FirstPlanAddons({
        el: this.$el.find('.first_plan_addons')
      });
    },

    hideAll: function () {
      this.basic.$el.hide();
      this.shipping.$el.hide();
      this.addons.$el.hide();
    },

    showBasic: function () {
      this.hideAll();
      this.basic.$el.show();
    },

    showShipping: function () {
      this.hideAll();
      this.shipping.$el.show();
    },

    showOptions: function () {
      this.hideAll();
      this.addons.$el.show();
    }

  });

  return FirstPlan;

});