define(['jquery', 'app/in_field_label'], function ($) {

  var handle = $('#city-select .current-city'),
      dropdownSelector = '#city-select section.mega-dropdown';
      dropdown = $(dropdownSelector);

  // Add handler method only if handle exists
  // in the document.
  if (handle) {
    $('body')
      .click(onBodyClick);
    handle
      .click(onHandlerClick);
  }

  $("#city-select label").inFieldLabels();

  /**
   * Listens to clicks on the whole documents, hides the
   * dropdown when the user clicks outside it.
   * @param   {Object}   e -> the event being handled
   */
  function onBodyClick(e) {
    e.target = $(e.target);
    // If clicked on the handle or the dropdown
    // or anything within the dropdown, this should do nothing.
    // Clicking anywhere else should close the dropdown.
    if (e.target[0] != handle[0] &&
        e.target[0] != dropdown[0] &&
        e.target.parents(dropdownSelector)[0] != dropdown[0]) {
      dropdown.fadeOut(200);
    }
  }

  /**
   * Listening to clicks on the handle.
   * Hides/shows the dropdown.
   */
  function onHandlerClick() {
    dropdown.fadeToggle(200);
  }

  /*
   * Slice the list of cities into 3 columns.
   */
  var cities = $('#city-select .featured-cities p'),
      eachColumn = Math.ceil(cities.length / 3);
      divs = [$('<div />'), $('<div />'), $('<div />')];
  cities.each(function (i, obj) {
    divs[Math.floor(i / eachColumn)].append(obj);
  });
  $('#city-select .featured-cities')
    .append(divs[0].addClass('first'))
    .append(divs[1])
    .append(divs[2]);
});
