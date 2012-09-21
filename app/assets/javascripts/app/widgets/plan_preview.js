/*jslint indent: 2*/
/*global define,window,Math*/
define([
  'jquery', 'lib/jquery.tmpl', 'lib/jquery.colorbox'
], function ($) {
  'use strict';

  function PlanPreviewManager() {
    this.cachedData = {};
  }


  PlanPreviewManager.prototype.init = function () {
    this.initLinks($('a[data-plan-preview]'));
  };


  PlanPreviewManager.prototype.initLinks = function (links) {
    var that;

    that = this;
    links.live('click', function (e) {
      e.preventDefault();
      that.showPreview($(this).data('plan-preview'));
    });
  };


  PlanPreviewManager.prototype.showPreview = function (planId) {
    this.fetchPlanData(planId, function (planData) {
      $.colorbox({
        html: this.renderPlanHtml(planData),
        width: 660
      });
    });
  };

  PlanPreviewManager.prototype.fetchPlanData = function (planId, callback) {
    if (this.cachedData[planId]) {
      callback.call(this, this.cachedData[planId]);
    } else {
      $.get('/plans/' + planId + '/summary.json', $.proxy(function (data) {
        this.cachedData[planId] = data;
        callback.call(this, data);
      }, this));
    }
  };

  PlanPreviewManager.prototype.renderPlanHtml = function (planData) {
    return $('#planPreviewTemplate').tmpl(planData);
  };

  return new PlanPreviewManager();
});
