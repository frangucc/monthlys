define('wizard_title', ['jquery', 'backbone'], function () {

  var WizardTitle = Backbone.View.extend({

    template: null,

    initialize: function () {
      this.template = _.template($('#templates .wizard_title').html());
      this.render();
    },

    render: function () {
      this.$el.html(this.template({
        heading: this.options.heading,
        paragraph: this.options.paragraph
      }));
    }

  });

  return WizardTitle;

});