define(['app/in_field_label', 'app/modalvideo'], function () {

  // Remove image and play video on click.
  $('section.video .frame img').click(function () {
    $(this).parent().html('<iframe width="660" height="395" src="//www.youtube.com/embed/opy9QemC-dc?rel=0&showinfo=0&wmode=transparent&autoplay=1" frameborder="0" allowfullscreen></iframe>');
    return false;
  });

  // All you need to get started banner
  (function () {

    var current = 2
      , rotating = true
      , items = $('section.allyouneed li')
      , figures = $('section.allyouneed figure')
      , schedule = null;

    function next() {
      current = (current + 1) % 3;
      select(current);
      if (rotating) {
        scheduleNext();
      }
    }

    function select(i) {
      current = i;
      items
        .removeClass('selected')
        .eq(i).addClass('selected');
      figures.filter(':visible').animate({
        opacity: 0
      }, {
        complete: function () {
          figures.eq(i).animate({ opacity: 1 })
        }
      });
    }

    function scheduleNext() {
      schedule = setTimeout(next, 5000);
    }

    function stopRotating() {
      rotating = false;
      clearTimeout(schedule);
    }

    function startRotating() {
      rotating = true;
      scheduleNext();
    }

    items.bind({
      click: function () {
        stopRotating();
        select($(this).index());
      }
    });
    figures.bind({
      mouseout: function () {
        startRotating();
      },
      mouseover: function () {
        stopRotating();
      }
    });

    next();

  }());

  // Sign up lables
  $('section.signup label').inFieldLabels();

  // Preferences
  (function () {

    var w = $('section.preferences')
      , showcase = w.find('div.showcase')
      , count = showcase.find('li').length
      , current = 0
      , locked = false;


    function select(type) {
      if (!locked) {
        locked = true;
        showcase.find('article:visible').fadeOut(function () {
          showcase.find('article#' + type).fadeIn(function () {
            locked = false;
          });
        });
      }
    }

    function random() {
      select(w.find('section li.selected:eq(0)').attr('id'));
    }

    random();

    w.find('section li').click(function () {
      if (locked) { return; }

      $(this).toggleClass('selected');
      if ($(this).is('.selected')) {
        select($(this).attr('id'));
      }
      else {
        random();
      }
    });

  }());

});
