define('list_business',
  ['wizard_forms', 'jquery', 'jquery.colorbox', 'backbone'],
  function (WizardForms) {

    var ListBusiness = Backbone.View.extend({

      template: null,

      fieldViews: null,

      events: {
        'submit .wizard_form': 'onSubmitForm',
        'click .next': 'onNext'
      },

      initialize: function () {
        this.template = _.template($('#templates .list_business').html());
        this.fieldViews = [];
        this.render();
      },

      render: function () {
        this.$el.html(this.template());
        this.fieldViews = [
          new WizardForms.Field({
            el: this.$el.find('.business_name input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.city input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.state input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.zip input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.email input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.phone input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.website input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.Field({
            el: this.$el.find('.address input'),
            validation: function (value) {
              return value !== '';
            }
          }),
          new WizardForms.SelectField({
            el: this.$el.find('.business_type select')
          }),
          new WizardForms.Field({
            el: this.$el.find('.business_description textarea'),
            validation: function (value) {
              return value !== '';
            }
          })
        ];
        this.$el.find('.terms a').colorbox({
          inline: true,
          href: '.list_business_terms_modal',
          width: 700,
          height: 625,
          fixed: true,
          scrolling: false,
          opacity: 0.8
        });
      },

      onNext: function () {
        this.$el.find('.wizard_form').submit();
        return false;
      },

      onSubmitForm: function () {
        if (this.validate()) {
          window.router.navigate('/welcome', true);
        }
        return false;
      },

      validate: function () {
        var fields = this.fieldViews,
            passed = true;
        for (var i = 0, top = fields.length; i < top; i++) {
          if (!fields[i].validate()) {
            passed = false;
          }
        }
        return passed;
      }

    });

    return ListBusiness;

  }
);