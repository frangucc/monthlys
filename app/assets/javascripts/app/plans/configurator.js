/*jslint indent: 2*/
/*global define,window*/
define(['jquery', 'app/routes'], function ($, Routes) {
  'use strict';

  function PlanConfigurator() {}


  /**
   * Return an array of ids of the selected options
   */
  PlanConfigurator.prototype.getSelectedOptionsId = function () {
    var optionsId, optionsSelect;

    optionsId = [];
    optionsSelect = $('.configuration .option-group select');

    optionsSelect.each(function (index, select) {
      var value = $(select).val();

      if (typeof value === 'number' || typeof value === 'string') {
        optionsId.push(value);
      } else if (value !== null) { // It's a list of values
        $.merge(optionsId, value);
      }
    });

    return optionsId;
  };


  /**
   * Returns select plan_recurrence_id
   */
  PlanConfigurator.prototype.getSelectedPlanRecurrenceId = function () {
    return $('#plan_recurrence_id').val();
  };


  /*
   * Returns the subscription params:
   *  - Plan recurrence id
   *  - Option ids
   *  - Coupon code (if applicable)
   *  - Source URL (if applicable)
   */
  PlanConfigurator.prototype.getSubscriptionParams = function (otherParams) {
    var subscriptionParams;

    subscriptionParams = {
      plan_recurrence_id: this.getSelectedPlanRecurrenceId(),
      options_id: this.getSelectedOptionsId()
    };
    if (this.coupon) {
      subscriptionParams.coupon_code = this.coupon;
    }
    if (this.source) {
      subscriptionParams.source = this.source;
    }
    if (otherParams !== undefined) {
      $.extend(subscriptionParams, otherParams);
    }

    return subscriptionParams;
  };


  /**
   * Will refresh the front-end totals when changing the plan_recurrence or any option drop-downs
   */
  PlanConfigurator.prototype.updateTotals = function () {
    var price, params;

    price = $('strong.main-price');
    params = this.getSubscriptionParams();

    price.html('...');
    $.get(Routes.displayTotals + '?' + $.param(params), function (data) {
      price.html('$' + data.recurrent_total + ' ' + data.billing_desc);

      $(data.refresh_options).each(function (index, option) {
        $('.stylableselect option[value="' + option.id + '"]').html(option.billing_desc);
        $('.stylableselect div.listitem[data-value="' + option.id + '"] .priceDesc').html(option.billing_desc);
      });

      if (data.first_time_total !== data.recurrent_total) {
        $('#first-time-fee .figure').html('$' + data.first_time_total);
      } else {
        $('#first-time-fee').hide();
      }

      $('.old-price strong').html(data.old_price);
    });
  };


  /**
   * Returns the handler for the subscribe action (Buy now or gift)
   */
  PlanConfigurator.prototype.getSubscribeHandler = function (subscriptionOptions) {
    return $.proxy(function (event) {
      event.preventDefault();
      this.subscribe(subscriptionOptions);
    }, this);
  };


  /**
   *
   */
  PlanConfigurator.prototype.getZipcodeHandler = function (form, subscriptionOptions) {
    return $.proxy(function (response) {
      var messagesBox, status, message;

      messagesBox = $('#colorbox #messages-container');
      status = response.status;
      message = response.message;

      if (status === 'error') {
        messagesBox.displayMessage(status, message);
        $.colorbox.resize();
      } else { // If success, the plan is now available for the user
        this.subscribe($.extend(subscriptionOptions,
                                { zipcode_validated: true }));
      }
    }, this);
  }


  /**
   * Shows a modal form asking for a zipcode in a valid area for the plan
   */
  PlanConfigurator.prototype.zipcodeConfirmation = function (subscriptionOptions) {
    $.colorbox({
      href: Routes.zipcodeConfirmation,
      width: 580,
      onComplete: $.proxy(function () {
        var form = $('#colorbox .zipcode form');

        form.submit($.proxy(function (e) {
          e.preventDefault();
          $.post(form.attr('action'),
                 form.serialize(),
                 this.getZipcodeHandler(form, subscriptionOptions));
        }, this));
      }, this)
    });
  }


  /**
   * Handles the subscribe action validations and redirect
   */
  PlanConfigurator.prototype.subscribe = function (options) {
    var params;

    if (!this.deliversToUser && (!options || !options.zipcode_validated)) {
      this.zipcodeConfirmation(options);
    } else {
      params = this.getSubscriptionParams();
      if (options && options.is_gift) {
        params.is_gift = true;
      }

      window.location.href = Routes.configuratorCheckout + '?' + $.param({ subscription: params });
    }
  }


  PlanConfigurator.prototype.bindEvents = function () {
    var changeHandler = $.proxy(function () {
      this.updateTotals();
    }, this);

    $('#plan_recurrence_id').change(changeHandler);
    $('.configuration .option-group select').change(changeHandler);

    $('#buy-now').click(this.getSubscribeHandler());
    $('.gift-now').click(this.getSubscribeHandler({ is_gift: true }));
  };


  PlanConfigurator.prototype.init = function (options) {
    this.source = options.source;
    this.coupon = options.coupon;
    this.deliversToUser = options.deliversToUser;

    this.updateTotals();
    this.bindEvents();
  };


  return new PlanConfigurator();

});
