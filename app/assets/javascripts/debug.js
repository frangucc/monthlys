define(function ($) {
  return {
    log: function log() {
      if (_debug) {
        console.debug.apply(console , arguments);
      }
    }
  }
});
