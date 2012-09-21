define(['jquery', 'lib/jquery.sexyselect', 'lib/jquery.sortable'], function ($) {

  $.fn.planOptions = function () {
    return $(this).each(function (index, formset) {
      createQuestionList($(formset));
    });
  }

  function createQuestionList(formset) {
    /*
     * TODO: We've to test this once a plan has real
     * data, right now we're not getting any question
     * list item from the start, so I'm not able
     * to check whether this is working properly or not.
     */
    var handle = $('#questions-add-formset'),
        list = $('<ul />');

    list
      .addClass('question-list')
      .insertBefore(handle);

    handle
      .bind({
        added: function (event, item) {
          createQuestionListItem(formset, $(item));
        }
      });

    formset
      .data({
        handle: handle,
        list: list
      });

    formset.find('.formset-fields > .formset-field')
      .each(function (index, item) {
        createQuestionListItem(formset, $(item));
      });
  }

  function createQuestionListItem(formset, item) {
    var listItem = $('<li />');

    item.find('.DELETE').hide();
    $('<a href="">Remove</a>')
      .addClass('remove')
      .bind({
        click: function () {
          item
            .parent()
            .hide()
            .find('.DELETE input:checkbox')
            .attr('checked', 'checked');
          return false;
        }
      }).appendTo(item);
    createAnswerList(item);
    item.find('.option_type select').sexySelect();

    listItem
      .addClass('formset-field-wrapper')
      .appendTo(formset.data('list'))
      .append(item);

    formset.data('list').sortable();
  }

  function createAnswerList(formset) {
    var handle = formset.find('.add'),
        list = $('<ul />');

    list
      .addClass('answer-list')
      .insertBefore(handle);

    handle
      .bind({
        added: function (event, item) {
          createAnswerListItem(formset, $(item));
        }
      });

    formset
      .data({
        handle: handle,
        list: list
      });
  }

  function createAnswerListItem(formset, item) {
    var listItem = $('<li />');

    listItem
      .addClass('formset-field-wrapper')
      .append(item);

    formset
      .data('list')
      .append(listItem)
      .sortable();

    item.find('.DELETE').hide();

    $('<a href="">Remove</a>')
      .addClass('remove')
      .bind({
        click: function () {
          item
            .parent()
            .hide()
            .find('.DELETE input:checkbox')
            .attr('checked', 'checked');
          return false;
        }
      })
      .appendTo(item);

    item.find('.option_type select').sexySelect();
  }

});
