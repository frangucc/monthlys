//= require active_admin/base

$(function () {
  // Tag highlights
  var m, select, initial;

  if ($('body').hasClass('admin_tag_highlights')) {
    m = {
      'Plan': $('#tag_highlights_plan_input'),
      'Category': $('#tag_highlights_category_input')
    }

    function updateType(selection) {
      $.each(m, function (k, v) {
        if (k == selection) {
          v.show();
        } else {
          v.hide();
        }
      });
    }

    select = $('select#tag_highlights_highlight_type');

    initial = select.find('option:selected').val();
    updateType(initial);

    select.change(function (e) {
      var selection = $(this).find('option:selected').val();
      updateType(selection);
    });
  }
});

$(function () {
  // $('input[type="submit"]').click(function (event) {
  $('body.admin_namespace form').submit(function (event) {
    // Not preventing default
    $(this)
      .find('input[type="submit"]')
        .val('Loading..')
        .attr('disabled', true);
  });
});
