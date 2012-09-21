define('plans/index', ['app/get_started', 'app/zip_modal', 'app/modalvideo'], function (getStarted, zipModal) {

  return {
    init: function (options) {
      getStarted.init();
      zipModal.init(options.zipModalOptions);
    }
  };

});
