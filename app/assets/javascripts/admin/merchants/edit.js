$(document).ready(function() {

  // Shipping types
  var displayShippingType = function() {
    var $this = $(this);
    $('#flat_rate, #state_dependant').hide();
    $('#shipping-types #' + $this.val()).show();
  };
  $("#shipping-types input:radio").click(displayShippingType);
  var checked = $("#shipping-types input:radio:checked");
  $.proxy(displayShippingType, checked)();

  // Taxation policies and rates
  $("#merchant_taxation_policy_no_taxes:radio").click(function(){
    $('#tax-rates').hide();
  });
  $("#merchant_taxation_policy_tax_plans:radio, #merchant_taxation_policy_tax_plans_plus_shippings:radio").click(function(){
    $('#tax-rates').show();
  });

  if($("#merchant_taxation_policy_no_taxes:radio").is(':checked')==false){
    $('#tax-rates').show();
  };

  // Merchant Custom Storefront
  $('#storefront ol li').not('li#merchant_custom_site_input').hide();

  $("#merchant_custom_site_input input").click(function(){
    $('#storefront ol li').not('li#merchant_custom_site_input').toggle();
  });

  if($("#merchant_custom_site_input input").is(':checked')==true){
    $('#storefront ol li').not('li#merchant_custom_site_input').show();
  };

});
