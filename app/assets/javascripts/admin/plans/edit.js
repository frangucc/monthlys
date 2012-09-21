(function () {
  var image_container, template;

  image_container = $("#images");
  template = $(".master-image").last();

  $('#add-master-image').click(function (e) {
    e.preventDefault();

    if (image_container.is(':visible')) {
      image_container.append(template.clone());
    } else {
      image_container.show();
    }
  });
})();
