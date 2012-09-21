define('videobox', [], function () {
  $('.video-box').each(function (e) {
    var playBtn, videoId, videoUrl;

    // Validate and parse video url/id.
    videoUrl = $(this).attr('data-video-url');
    if (!videoUrl) {
      return;
    }
    videoId = videoUrl.match(/\?v=(.*)/)[1];
    if (!videoId) {
      return;
    }

    $(this)
      .click(function (e) {
        var content;

        e.preventDefault();

        content = '<iframe type="text/html" width="640" height="385" src="//www.youtube.com/embed/' + videoId + '?autoplay=1&modestbranding=1&rel=0" frameborder="0"></iframe>';

        $.colorbox({ html: content });
      })
      .append('<span class="play"></span>');
  });
});
