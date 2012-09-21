define(['jquery'], function ($) {

  var api = {}; // Store public interface for chaining.

  /**
   * When the placeholder is loaded replace the
   * heavy images with it.
   */
  function onPlaceholderLoad() {
    var $this = $(this),
        selector = $this.data('selector'),
        placeholder = $this.data('placeholder');
    $(selector).each(function (i, elem) {
      // Do this only if the resource is not yet loaded.
      if (elem.complete !== true) {
        elem = $(elem);
        elem
          .data('src', elem.attr('src'))
          .bind('load.imageplaceholder', onImageLoad)
          .attr('src', placeholder);
      }
    });
  }

  /**
   * Make the image appear when it loads.
   */
  function onImageLoad() {
    var elem = $(this);
    // Remove previous handler.
    elem.unbind('load.imageplaceholder');
    elem.attr('src', elem.data('src'));
  }

  /**
   * Replace heavy images matched by selector and shows
   * placeholder while it loads.
   * @param   selector    -> to find images to replace
   * @param   placeholder   -> to replace with while image loads
   */
  function init(s, p) {
    $('<img />')
      .data({ selector: s, placeholder: p })
      .attr('src', p)
      .hide()
      .appendTo('body')
      .load(onPlaceholderLoad);
  }

  api.replace = function (s, p) {
    init(s, p);
    return api;
  };

  return api;

});
