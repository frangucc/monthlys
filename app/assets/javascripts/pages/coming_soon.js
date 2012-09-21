define(['jquery', 'lib/jquery.colorbox'], function ($) {

  if (!ask_for_zipcode) {
    $(document).ready(function () {
      $('#sharethis-modal img').ready(function () {
        $('#sharethis-modal .sharethis-links').height(30);
        $('#sharethis-modal').show();
        $.colorbox({
          href: '#sharethis-modal',
          inline: true,
          innerWidth: 600,
          fixed: true,
          onClosed: function () {
            $("#sharethis-modal").hide();
          }
        });
      });
    });
  }

  stLight.options({publisher: "b1f24b06-b680-489a-af4a-c90c57536a10"});
});
