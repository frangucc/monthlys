define(function () {
  return function (lat, lng, container, locationName) {

    var script = document.createElement('script');
    script.src = '//maps.googleapis.com/maps/api/js' +
      '?key=AIzaSyDl_CZ665i5gHCKGEKZEMAf_VU7Xg9oBXw' +
      '&sensor=false' +
      '&callback=initGoogleMap';
    document.body.appendChild(script);

    window.initGoogleMap = function () {
      var latlng = new google.maps.LatLng(lat, lng);
      var myOptions = {
        zoom: 14,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map(document.getElementById(container), myOptions);
      var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        title: locationName
      });
    }
  }
});
