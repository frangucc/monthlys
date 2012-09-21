define('first_plan_basic',
  ['wizard_bar', 'wizard_title', 'wizard_nav', 'wizard_forms',
   'document_list', 'jquery', 'backbone'],
  function (WizardBar, WizardTitle, WizardNav, WizardForms,
      DocumentList) {

    var FirstPlanBasic = Backbone.View.extend({

      fieldViews: null,

      initialize: function () {
        this.fieldViews = [];
        this.template = _.template($('#templates .first_plan_basic').html());
        this.render();
      },

      render: function () {
        this.$el.html(this.template());
        new WizardBar({
          el: this.$el.find('.wizard_bar'),
          step: 2
        });
        new WizardTitle({
          el: this.$el.find('.wizard_title'),
          heading: 'Basic Information',
          paragraph: 'A plan is a good, service or membership that members can subscribe to. You can have on plan with multiple options, or many plans. <a href="#">See examples</a>'
        });
        new WizardNav({
          el: this.$el.find('.wizard_nav'),
          onBack: $.proxy(this.onBack, this),
          onNext: $.proxy(this.onNext, this)
        });
        this.fieldViews = [
          new WizardForms.Field({
            el: this.$el.find('.plan_name input')
          }),
          new WizardForms.Field({
            el: this.$el.find('.tagline input')
          }),
          new WizardForms.Field({
            el: this.$el.find('.description textarea')
          }),
          new WizardForms.SelectField({
            el: this.$el.find('.offer_type .step1 select')
          }),
          new WizardForms.SelectField({
            el: this.$el.find('.offer_type .step2 select')
          }),
          new WizardForms.TokenizerField({
            el: this.$el.find('.categories input'),
            source: ['Hola', 'Hermoso', 'Chau', 'Culiao', 'Buen dia', 'Bobeta', 'Banana', 'Bostezo']
          }),
          new WizardForms.ImageField({
            el: this.$el.find('.image input')
          }),
          new WizardForms.Field({
            el: this.$el.find('.terms textarea')
          }),
          new WizardForms.Field({
            el: this.$el.find('.fineprint textarea')
          })
        ];
        new DocumentList({
          el: this.$el.find('.documents .document_list')
        });
      },

      onBack: function () {
        window.router.navigate('/fullfilment-assistance', true);
      },

      onNext: function () {
        alert("?");
      }

    });

    return FirstPlanBasic;

  }
);