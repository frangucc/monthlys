define('plan_configurators/gifting', ['jquery'], function ($) {

  function refreshGifting() {
    var giftDesc = $('#gifting .gift-desc');
    if ($('#gifting_is_gift').is(':checked')) {
      giftDesc.show();
    }
    else {
      giftDesc.hide();
    }
  }

  $('#gifting_is_gift').click(refreshGifting);
  refreshGifting();

});
