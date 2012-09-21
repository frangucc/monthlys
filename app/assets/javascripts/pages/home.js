define(['app/in_field_label'], function () {
  $('div.signup label').inFieldLabels();

  var section = $('section.plans')
  , articles = section.find('article')
  , items = section.find('ul.nav li')
  , count = current = items.length
  , animationSpeed = 800
  , animationSpeed2 = 1500
  , locked = false
  , rotate
  , rotationSpeed = 7000 + animationSpeed2; // 7 seconds between items

  function hideAll(callback) {
    articles.filter('.selected').find('div.box').animate({
      right: -500, opacity: 0
    }, {
      duration: animationSpeed
    });
    articles.filter('.selected').find('img').animate({
      right: -500, opacity: 0
    }, {
      duration: animationSpeed2,
      complete: function () {
        callback();
      }
    });
    articles.removeClass('selected');
  }

  function show(article) {
    article.addClass('selected')
    article.find('div.box').animate({
      right: 0, opacity: 1
    }, {
      duration: animationSpeed2
    });
    article.find('img').animate({
      right: 100, opacity: 1
    }, {
      duration: animationSpeed
    });
  }

  function select(i) {
    if (locked) { return; }
    current = i;
    items.removeClass('selected').eq(i).addClass('selected');
    hideAll(function () {
      show(articles.eq(i));
    });
    scheduleNext();
  }

  function stop() {
    clearTimeout(rotate);
  }

  function next() {
    current = (current + 1) % count;
    select(current);
  }

  function scheduleNext() {
    clearTimeout(rotate);
    rotate = setTimeout(next, rotationSpeed);
  }

  items.click(function () {
    select($(this).index());
  });
  articles.bind({
    mouseover : stop,
    mouseout  : scheduleNext
  });
  articles.find('div.box').css({
    right: -500, opacity: 0
  });
  articles.find('img').css({
    right: -500, opacity: 0
  });

  next();
});
