/*jslint indent: 2 */
/*global define,$,clearTimeout,setTimeout*/

define(['jquery', 'debug'], function ($, debug) {
  'use strict';
  var searchWrapper, searchForm, searchInput, results, timer, clearTextButton, loader, minQueryLen;

  minQueryLen = 2;

  searchWrapper = $('#search');
  searchForm = searchWrapper.children('form');
  searchInput = searchForm.children('input[type=text]');

  function clearResults() {
    if (results) {
      results.slideUp(200, 'swing', function () {
        $(this).remove();
        results = undefined;
      });
    }
  }

  function showResults(data) {
    var resultsHtml, i;

    if (data.length === 0) {
      resultsHtml = '<p class="title">No results found.</p>';
    } else {
      resultsHtml = '<p class="title">Quick results</p>';
      for (i = 0; i < data.length; i += 1) {
        resultsHtml += '<div class="result-item">'
          + '<a href="' + data[i].url + '">'
          + '<img src="' + data[i].image_url + '" alt="">'
          + '<p class="title">' + data[i].title + '</p>'
          + '<p class="merchant">from <em>' + data[i].merchant + '</em></p>'
          + '<p class="description">Get it for <strong>' + data[i].price_description + '</strong></p>'
          + '</a>'
          + '</div>';
      }
    }

    results = $('<div id="search-results">' + resultsHtml + '</div>').css('display', 'none');
    searchWrapper.append(results);
    results.slideDown(200, 'swing');
  }

  function searchTerm(q) {
    clearResults();

    debug.log('Search started...');

    clearTextButton.hide();
    loader.show();

    $.getJSON('/search.json?q=' + q, function (data) {
      debug.log('Search finished.', data.results);
      loader.hide();

      if (searchInput.is(':focus')) {
        showResults(data.results);
        if (searchInput.val().length !== 0) {
          clearTextButton.show();
        }
      }
    });
  }

  loader = $('<div class="loader"></div>').css('display', 'none');
  searchForm.append(loader);

  clearTextButton = $('<div class="clear-text-button"></div>')
    .click(function () {
      searchInput.val('');
      $(this).hide(0, function () {
        searchInput.focus();
      });
    })
    .css('display', 'none');
  searchForm.append(clearTextButton);

  // Listen search input changes, trigger search.
  searchInput.keyup(function () {
    var q = $(this).val();
    debug.log('Search query changed: ' + q);
    clearTimeout(timer);

    clearTextButton.toggle(q.length !== 0);

    if (q.length > minQueryLen) {
      timer = setTimeout(function () { searchTerm(q); }, 300);
    }
  });

  searchInput.data('original_width', searchInput.css('width'));
  searchInput.focus(function () {
    var q = searchInput.val();

    if (q.length > minQueryLen) {
      timer = setTimeout(function () { searchTerm(q); }, 1);
    }

    $(this).animate({ width: '130px' }, 200, function () {
      if (q.length > 0 && q.length <= minQueryLen) {
        clearTextButton.show();
      }
    });
  });



  // If the search input looses focus, cancel current search, clear
  // previous search results and clear entered text.
  searchInput.blur(function () {
    debug.log('Clearing search.');

    clearTextButton.hide();
    loader.hide();


    if (results && !results.is(':hover')) {
      // Didn't click a result
      if (!clearTextButton.is(':hover')) {
        // Didn't click the text button.
        $(this).animate({ width: $(this).data('original_width') }, 200);
      }
      clearResults();
      clearTimeout(timer);
    }
  });

  // Disable submit
  searchForm.submit(function (event) {
    event.preventDefault();
  });
});
