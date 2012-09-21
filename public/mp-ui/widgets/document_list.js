define('document_list', ['jquery', 'backbone'], function () {

  var DocumentList = Backbone.View.extend({

    events: {
      'click a.add_document': 'onClickAdd'
    },

    initialize: function () {
      this.render();    
    },

    render: function () {
      this.$el.html($('#templates .document_list').html());
    },

    onClickAdd: function () {
      var doc = new DocumentListItem({
        el: $('<li />')
      });
      doc.$el.appendTo(this.$el.find('.documents'));
      return false;
    }

  });

  var DocumentListItem = Backbone.View.extend({

    events: {
      'click a.remove_document': 'onClickRemove'
    },

    initialize: function () {
      this.render();
    },

    render: function () {
      this.$el
        .addClass('document_list_item')
        .html($('#templates .document_list_item').html()); 
    },

    onClickRemove: function () {
      this.remove();
      return false;
    }

  });

  return DocumentList;

});