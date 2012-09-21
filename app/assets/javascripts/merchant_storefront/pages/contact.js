define(['app/google_map'], function (maps) {

  // Load the maps with the mark on the vars created ont he view.
  if (merchant.show_location && merchant.lat && merchant.lng) {
    maps(merchant.lat, merchant.lng, 'map-canvas', merchant.business_name);
  }

});
