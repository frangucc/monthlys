define(['jquery'], function ($) {

  // Boundaries for the swiping button.
  var maxLeft = 38,
      minLeft = -1,
      clickedAt = null,
      userOptions = {},
      locked = false;

  /**
   * Called when the user stops holding the click.
   */
  function holdSwipeStop(e) {
    // this => buttontrack
    $(document.body)
      .unbind('mousemove.swipe')
      .unbind('mouseup.swipe');
    $.proxy(evalSwipe, this)(e);
  }

  /**
   * Resets the position of the cursor while holding click
   * and moving.
   */
  function holdSwipeFollow(e) {
    var offset = this.parent().offset(),
        calc;
    this
      .css({
        left: (calc = (e.clientX - offset.left) - (this.width() / 2)) < minLeft ?
          minLeft : calc > maxLeft ? maxLeft : Math.round(calc)
      });
  }

  /**
   * When the user holds pressed click on the button, he/she
   * can move it from side to side.
   */
  function holdSwipe(e) {
    if (locked === true) {
      return;
    }
    var buttontrack = $(this),
        follow = $.proxy(holdSwipeFollow, buttontrack.find('.button'));
        stop = $.proxy(holdSwipeStop, buttontrack);
    clickedAt = new Date();
    $(document.body)
      .bind('mousemove.swipe', follow)
      .bind('mouseup.swipe', stop);
    return false;
  }

  /**
   * When the user drops the button, it sets to the opposite
   * side.
   */
  function evalSwipe(e) {
    var buttontrack = $(this),
        button = buttontrack.find('.button'),
        buttontrackWidth = buttontrack.width(),
        buttonWidth = button.width(),
        buttonPosition = buttontrack.find('.button').position();
    // If user clicked.
    if (buttontrack.has(e.target) &&
        (new Date().getTime() - clickedAt.getTime()) < 200) {
      $.proxy(swipeToggle, buttontrack)();
    }
    else{
      if (buttonPosition.left >= ((buttontrackWidth - buttonWidth) / 2)) {
        $.proxy(swipeToOn, buttontrack)();
      }
      else {
        $.proxy(swipeToOff, buttontrack)();
      }
    }
  }

  /**
   * Slides to the "On" position.
   */
  function swipeToOn() {
    if (locked === true) {
      return;
    }
    var buttontrack = this;
    buttontrack
      .find('.button')
      .animate({
        left: maxLeft
      }, {
        duration: 200,
        complete: function () {
          buttontrack.addClass('on');
        }
      });
    if (!buttontrack.is('.on')) {
      typeof userOptions.onTurnedOn === 'function' ?
        userOptions.onTurnedOn(buttontrack) : false;
    }
  }

  /**
   * Slides to the "Off" position.
   */
  function swipeToOff() {
    if (locked === true) {
      return;
    }
    var buttontrack = this;
    buttontrack
      .find('.button')
      .animate({
        left: minLeft
      }, {
        duration: 200,
        complete: function () {
          buttontrack.removeClass('on');
        }
      });
    if (buttontrack.is('.on')) {
      typeof userOptions.onTurnedOff === 'function' ?
        userOptions.onTurnedOff(buttontrack) : false;
    }
  }

  /**
   * If on, shows off. If off, shows on.
   */
  function swipeToggle() {
    var buttontrack = this;
    buttontrack.is('.on') ? $.proxy(swipeToOff, buttontrack)() : $.proxy(swipeToOn, buttontrack)();
  }

  /**
   * Locks the swipe and it cant move.
   */
  function lock() {
    locked = true;
  }

  /**
   * The swipe can move again.
   */
  function unlock() {
    locked = false;
  }

  /**
   * Call the module with options to make it configurable.
   */
  return {
    init: function (selector, options) {
      var element = $(selector);
      userOptions = options;
      if (element.is('.large')) {
        maxLeft = 60;
      }
      element.bind({
        mousedown: holdSwipe,
        click: function () { return false; }
      });
    },
    turnOn: swipeToOn,
    turnOff: swipeToOff,
    lock: lock,
    unlock: unlock
  };

});
