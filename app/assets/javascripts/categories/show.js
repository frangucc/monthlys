define([
  'app/swipe_subscription', 'app/image_placeholder', 'app/sidebar'
], function (swipe, placeholder) {

  placeholder
    .replace('li.plan-block a.shadow img', '/assets/default/plan-thumbnail.png')
    .replace('ul.plan-list img', '/assets/default/plan-thumbnail.png')
    .replace('img.combo-img', '/assets/default/plan-icon.png');

  var swipeOptions = {
    onTurnedOn: function (buttontrack) {
      window.location.href = $(buttontrack).parents('a').attr('href') + '#on';
    },
    onTurnedOff: function (buttontrack) {
      window.location.href = $(buttontrack).parents('a').attr('href') + '#off';
    }
  };
  swipe.init('li.combo:not(.no-swipe) .buttontrack, li.plan-block:not(.no-swipe) .buttontrack', swipeOptions);

  // Deactivate no-swipes
  $('li.combo.no-swipe .buttontrack, li.plan-block.no-swipe .buttontrack')
    .css({
      opacity: 0.5,
      cursor: 'not-allowed'
    })
    .click(function () {
      return false;
    });

  // Get started banner hide and save in session
  $('section.get_started .close').click(function () {
    $('section.get_started').hide(700, function () {
      $(this).remove();
    })
    $.get('/settings/persistent_dismiss?name=get_started');
    return false;
  });

});
