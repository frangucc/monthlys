define(['app/ajax_signup', 'app/messages'], function (AjaxSignUp) {
  var messagesContainer = $('.messages');

  var sendLinkToBack = function (link, deleted) {
    var remove = link.is('.removable') && deleted;
    link
      .addClass('moving')
      .animate({
        left: '-100%',
        opacity: remove? 0 : 1
      }, {
        duration: 200,
        complete: function () {
          if (remove) {
            link.remove();
            if ($('section.categories_grid .user-preference-link').length === 0) {
              messagesContainer.displayMessage('success', "You haven't selected any preference just yet.")
            }
          }
          else {
            link
              .removeClass('moving')
              .prependTo(link.parent())
              .animate({
                left: 0
              });
          }
        }
      })
      .find('.checkbox').animate({ opacity: 1 });
  };

  var preferenceNewJSONSuccess = function (data, link) {
    messagesContainer.displayMessage(data.status, data.message);
    link.addClass('active');
    link.attr('href', '/user_preferences/' + data.user_preference.id);
  };

  var preferenceDestroyJSONSuccess = function (data, link) {
    messagesContainer.displayMessage(data.status, data.message);
    link.removeClass('active');
    link.attr('href', '/user_preferences?' + $.param({ user_preference: { category_id: data.user_preference.category_id } }));
  };

  var preferenceDestroy = function (link, box) {
    $.ajax({
      type: 'DELETE',
      url: link.attr('href'),
      success: function(data) {
        preferenceDestroyJSONSuccess(data, link);
        sendLinkToBack(box, true);
      }
    });
  };

  $('.user-preference-link .checkbox').click(function (event) {
    if (userSignedIn) {
      var $this = $(this),
          box = $this.parent().parent();

      if (box.is('.active')) {
        preferenceDestroy($this, box);
      }
      else {
        $.post($this.attr('href'), function(data) {
          preferenceNewJSONSuccess(data, $this);
          sendLinkToBack(box);
        });
      }

      box
        .toggleClass('active')
        .find('.checkbox')
          .animate({ opacity: 0.2 });
    }
    else {
      AjaxSignUp.signUp();
    }

    event.preventDefault();
    return false;
  });

  $('.user-preference-link .close').click(function () {
    //$(this).parent().find('.checkbox').click();
    sendLinkToBack($(this).parent());
  });

  /***** GRID DISPLAY *****/

  var fragment = document.createDocumentFragment()
    , categories = $('section.categories_grid .user-preference-link')
    , grid = []
    , columnCount = 4, rowCount = 2
    , columnIndex, rowIndex
    , column;

  /*
   * Disable grid if user is at "My Preferences".
   * If there's no link at my preferences we assume that
   * the user has loaded the page with his preferences
   * and not the grid with all the categories.
   */
  $('ul.user-preferences-nav li:eq(0) a').each(function () {
    rowCount = Math.ceil(categories.length / columnCount);
  });

  categories.each(function (index, object) {
    var i, topI;
    object = $(object);
    columnIndex = index % columnCount;
    rowIndex = Math.floor(index / columnCount) % rowCount;
    if (typeof grid[columnIndex] === 'undefined') {
      grid[columnIndex] = [];
      for (i = 0, topI = rowCount; i < topI; i++) {
        grid[columnIndex].push($('<div class="row" />'));
      }
      column = $('<div class="column" />');
      for (i = 0, topI = rowCount; i < topI; i++) {
        column.append(grid[columnIndex][i]);
      }
      fragment.appendChild(column.get(0));
    }
    grid[columnIndex][rowIndex].append(object);
  });
  $('section.categories_grid').prepend(fragment);

  /***** RESIZE ROWS *****/

  function resizeRow(row, obj) {
    if (row.outerHeight() < obj.outerHeight()) {
      row.css('height', (obj.outerHeight()) + 'px');
    }
  }

  function resizeRows() {
    $('section.categories_grid .row').removeAttr('style');
    $('section.categories_grid img').each(function (index, object) {
        var row = $(object).parents('.row')
          , item = $(object).parents('.user-preference-link');

        if (object.complete) {
          resizeRow(row, item);
        }
        else {
          $(object).load(function () {
            resizeRow(row, item);
          });
        }
      });
  }

  resizeRows();
  $(window).resize(resizeRows);

});
