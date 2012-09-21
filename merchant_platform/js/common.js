/*jslint indent: 4 */
/*global define*/

define(['jquery', 'lib/jquery.livequery', 'lib/jquery.imagewidget', 'lib/jquery.sexyselect'], function () {
  $('input[type="file"]:visible').livequery(function () {
      $(this).imageWidget();
  });

  $('select:visible').livequery(function () {
      $(this).sexySelect();
  });
});
