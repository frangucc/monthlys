define('slidebutton', ['jquery'], function($) {

  $(".buttontrack").each(function() {
    var $this = $(this);
    if ($this.hasClass("on")) {
      $this
        .children(".button")
          .animate({"marginLeft" : "37px"}, 30)
          .children(".label")
            .html("On");
    }
    else {
      $this
        .children(".button")
          .animate({"marginLeft" : "-1px"}, 30)
          .children(".label")
            .html("Off");
    }
  });

});
