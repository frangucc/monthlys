define([
  'app/get_started', 'app/image_placeholder', 'app/zip_modal',
  'app/flex_slider', 'app/sidebar', 'app/messages'
], function (getStarted, placeholder, zipModal) {

  return {
    init: function (options) {
      placeholder.replace('li.plan-block a.shadow img', '/assets/default/plan-thumbnail.png');
      getStarted.init();
      zipModal.init(options.zipModalOptions);
    }
  };

});
