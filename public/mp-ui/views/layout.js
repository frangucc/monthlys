define('layout', ['jquery', 'backbone'], function () {

  var Layout = Backbone.View.extend({

    /**
     * View that is currently on display.
     */
    currentView: null,

    initialize: function () {
      this.template = _.template($('#templates .layout').html());
      this.render();
    },

    render: function () {
      this.$el
        .html(this.template())
        .addClass('layout')
        .appendTo('#application');
    },

    setView: function (view) {
      view.$el
        .hide()
        .appendTo(this.$el.find('.content'));
      if (this.currentView !== null) {
        this.currentView.$el.hide();
      }
      view.$el.show();
      this.currentView = view;
    }

  });

  // Set layout as global variable.
  window.layout = window.layout || new Layout();

  // Return layout to use as module response.
  return window.layout;

});