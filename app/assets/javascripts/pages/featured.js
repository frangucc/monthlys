define(['jquery', 'plans/video_reviews', 'app/widgets/multislider'], function ($, videoReviews) {

  return {
    init: function (context) {
      $('.small-highlights .items').multislider();
      videoReviews.init({ selector: '.video-review-link' });
    }
  };

});
