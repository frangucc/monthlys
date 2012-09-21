/*jslint indent: 4 */
/*global define*/

define(['common', 'lib/jquery.wmd', 'widgets/formset_init'], function () {
  $('#id_details').wmd({});

  $('.formset').livequery(function () {
      var fs = $(this);
      fs.formsetInit({
          tplId: fs.data('tplid'),
          formsetFormsId: fs.data('formsetformsid'),
          formsetPrefix: fs.data('formsetprefix'),
          addId: fs.data('addid'),
          formsetCanDelete: fs.data('formsetcandelete')
      });
  });

  // Plan types
  var plan_types = window.plan_types
    , field = $('.plan_type .control')
    , first = field.find('select:first')
    , last  = field.find('select:last');

  function buildSecondSelect(value) {
    var options = plan_types[field.find(':input:first').val()]
      , selectHTML = []
      , newSelect = $('<select />');

    field.find('select').remove();
    field.find('.sexyform-select:gt(0)').remove();

    $(options).each(function (index, option) {
      selectHTML.push('<option value="' + option[0] + '">' + option[1] + '</option>');
    });
    newSelect
      .attr('name', 'plan_type[sub_type]')
      .html(selectHTML.join(''))
      .insertAfter(field.find('.sexyform-select:first'))
      .val(value);
  }

  // Sexy select generates a hidden input instead of the select.
  field.find('input').change(function () {
    buildSecondSelect();
  });

  // Filter second select options at start.
  buildSecondSelect(last.val());
});
