define(['jquery', 'plans/video_reviews'], function ($, videoReviews) {

  return {
    init: function (context) {
      videoReviews.init({ selector: '.video-review-link' });
    }
  };

});
