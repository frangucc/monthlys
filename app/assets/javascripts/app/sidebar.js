define(['jquery', 'lib/jquery.ui'], function ($) {
  var priceInputMin = $('#filter_min_price'),
      priceInputMax = $('#filter_max_price'),
      defaultMin = priceInputMin.val() || 1,
      defaultMax = priceInputMax.val() || 50,
      priceDisplay,
      priceDisplayMin,
      priceDisplayMax;

  priceInputMin.val(defaultMin);
  priceInputMax.val(defaultMax);

  priceDisplayMin = $('<div class="slider-display min">Min <span class="val">$'
                      + defaultMin + '</span></div>');
  priceDisplayMax = $('<div class="slider-display max">Max <span class="val">$'
                      + defaultMax + '</span></div>');
  priceDisplay = $('<div class="slider-display"></div>')
                   .append(priceDisplayMax)
                   .append(priceDisplayMin);

  $('#sidebar_price_slider')
    .after(priceDisplay)
    .slider({
      range: true,
      min: 1,
      max: 200,
      values: [defaultMin, defaultMax],
      slide: function(event, ui) {
        var min = ui.values[0],
            max = ui.values[1];

        // Update inputs
        priceInputMin.val(min);
        priceInputMax.val(max);
        // Update widget displays
        priceDisplayMin.children('.val').text('$' + min);
        priceDisplayMax.children('.val').html('$' + max);
      }
    });
});
