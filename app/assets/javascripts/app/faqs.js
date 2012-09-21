define('faqs', ['jquery'], function ($) {

  $('.drill-down').click(function (e) {
    e.preventDefault();
    $(this).toggleClass("expanded");
    var id = $(this).attr("rel");
    $("#"+id).toggle();
  });

});
