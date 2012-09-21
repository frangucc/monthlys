define(['jquery'], function ($) {

  /*
   * FAQ stuff
   */
  (function () {
    "use strict";

    var section = $('section.faqs')
      , ul = $('<ul />')
      , li;

    // Create a LI dom element for each article
    section.find('article').each(function () {
      li = $('<li />');
      li.html($(this).find('h1').html());
      li.attr('rel', $(this).attr('id'));

      // Tweak for the arrow
      $('<span />').appendTo(li);

      li.appendTo(ul);
    });

    // Insert the list right after the first heading
    ul.insertAfter(section.find('h1:first'));

    // Assign a handler to each li to show the article
    ul.bind({
      click: function (e) {
        var li = $(e.target);
        ul.find('li').removeClass('selected');
        li.addClass('selected');
        section.find('article').hide().filter('#' + li.attr('rel')).show();
      }
    });

    // Hide all articles except the first and select the li
    section.find('article:not(:first)').hide();
    ul.find('li:first').addClass('selected');

    // Add a class to the section so the layout can change based
    // on if the script ran on it or not.
    section.addClass('tabbed');

  }());

});
