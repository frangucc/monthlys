/*jslint indent: 2*/
/*global define*/
define(['jquery', 'app/widgets/image_slider'], function ($, ImageSlider) {
  'use strict';

  function SubscriptionArchive(planId) {
    this.planId = planId;
    this.cachedData = {};
  }


  SubscriptionArchive.setId = function (planId) {
    this.planId = planId;
  };


  SubscriptionArchive.prototype.urls = {
    archive: function (planId) {
      return '/plans/' + planId + '/subscription_archive.json';
    }
  };


  SubscriptionArchive.prototype.showOn = function (events, elements) {
    elements.on(events, $.proxy(function (e) {
      e.preventDefault();
      this.showModal();
    }, this));
  };


  SubscriptionArchive.prototype.showModal = function () {
    this.fetchData(function (archiveData) {
      $.colorbox({
        html: this.renderHtml(archiveData),
        width: 660
      });
    });
  };


  SubscriptionArchive.prototype.fetchData = function (callback) {
    if (this.cachedData[this.planId]) {
      callback.call(this, this.cachedData[this.planId]);
    } else {
      $.get(this.urls.archive(this.planId), $.proxy(function (data) {
        this.cachedData[this.planId] = data;
        callback.call(this, data);
      }, this));
    }
  };


  SubscriptionArchive.prototype.renderHtml = function (archiveData) {
    var wrapper, imgs, slider;

    wrapper = $('<div class="image-nav" id="subscription-archive-content"/>');
    imgs = $('#planSubscriptionArchiveTemplate').tmpl(archiveData).appendTo(wrapper);

    slider = new ImageSlider(wrapper)
    slider.init();

    return wrapper;
  };


  return SubscriptionArchive;
});
