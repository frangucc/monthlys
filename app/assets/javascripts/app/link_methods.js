define(['jquery'], function ($) {
  // Based on rails jquery-ujs
  function handleMethodClick(link) {
    var href, method, target, csrf_token, csrf_param, form, metadata_input;

    href = link.attr('href');
    method = link.data('method');
    target = link.attr('target');
    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');
    form = $('<form method="post" action="' + href + '"></form>');
    metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

    if (csrf_param !== undefined && csrf_token !== undefined) {
      metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
    }

    if (target) { form.attr('target', target); }

    form.hide().append(metadata_input).appendTo('body');
    form.submit();
  }

  function bindEvents() {
    $('a[data-method]').click(function (e) {
      e.preventDefault();
      handleMethodClick($(this));
    });
  }

  bindEvents();
});
