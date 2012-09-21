/*jslint indent: 2*/
/*global define,window*/
define(['jquery'], function ($) {
  'use strict';

  function PlanTabs() {}

  PlanTabs.prototype.init = function () {
    var clickHandler;

    this.hash = window.location.hash;
    this.tabs = $('div.plan-info');
    this.handles = this.tabs.find('ul.tabs-headers li a');
    this.contents = this.tabs.find('section');
    clickHandler = this.getClickHandler();

    this.bindEvents(clickHandler);
    this.selectInitialTab(clickHandler);
  };

  PlanTabs.prototype.bindEvents = function (clickHandler) {
    this.handles.click(clickHandler);
  };

  PlanTabs.prototype.selectInitialTab = function (clickHandler) {
    var active;

    if (!!this.hash) {
      active = this.handles.filter('[href="' + this.hash + '"]');
    } else {
      active = this.handles.get(0);
    }
    clickHandler.call(active);
  };

  PlanTabs.prototype.getClickHandler = function () {
    var that = this;

    return function () {
      var contentId;

      contentId = $(this).attr('href').substring(1);

      that.handles.removeClass('active');
      $(this).addClass('active');

      that.contents.hide();
      that.contents.filter('[id="' + contentId + '"]').show();

      return false;
    };
  };

  return new PlanTabs();
});
