/*jslint indent: 2*/
/*global define,window,Math*/
define([
  'jquery', 'app/ajax_signup', 'lib/jquery.tmpl', 'app/widgets/multislider', 'lib/jquery.easing'
], function ($, ajaxSignup) {
  'use strict';

  function Pulldown() {
    this.pulldown = $('.pulldown > .wrapper');
    this.currentData = null;
    this.items = null;
    this.cachedData = {};
    this.activeLink = null;
    this.showMore = null;
    this.links = [];
  }


  Pulldown.urls = {
    tag_highlights: function (tag_slug) {
      return '/tags/' + tag_slug + '/highlights.json';
    },
    more: '/categories/highlights.json',
    everything: '/plans/filtered?filter[discover]=everything'
  };


  /**
   * Initializes the widget, binds events.
   */
  Pulldown.prototype.init = function (options) {
    var slug, idx, now;

    this.blockItems = !options.userSignedIn;
    this.autoOpen = options.autoOpen;

    this.initLinks();

    if (this.autoOpen) {
      now = new Date();
      idx = (now.getDate() + now.getHours()) % (this.links.length - 1);

      slug = $('.tag-nav a').eq(idx).attr('data-slug');
      this.triggerChange({ type: 'tag', tag_slug: slug});
    }
  };


  /**
   * Initializes menu links: add extra items, binds events, add
   * classes, etc...
   */
  Pulldown.prototype.initLinks = function () {
    var that, linksContainer, tagClickHandler, moreClickHandler;

    that = this;
    linksContainer = $('.tag-nav > ul');
    tagClickHandler = function (e) {
      var tag_slug;

      e.preventDefault();
      tag_slug = $(this).attr('data-slug');
      that.triggerChange({ type: 'tag', tag_slug: tag_slug, link: $(this) });
    };
    moreClickHandler = function (e) {
      e.preventDefault();
      that.triggerChange({ type: 'more', link: $(this) });
    };

    linksContainer
      .find('a')
      .click(tagClickHandler)
      .data('type', 'tag');

    $('<a href="">More</a>')
      .data('type', 'categories')
      .addClass('more')
      .appendTo(linksContainer)
      .click(moreClickHandler)
      .wrap('<li/>');

    this.links = linksContainer.find('a');
  };


  /**
   * Triggers a pulldown current active item change.
   */
  Pulldown.prototype.triggerChange = function (options) {
    var link;

    if (!this.isLoading()) {
      this.loading(true);

      if (options.link !== undefined) {
        link = options.link;
      } else if (options.type === 'tag') {
        link = $('.tag-nav a[data-slug="' + options.tag_slug + '"]').eq(0);
      }
      this.changeActiveLink(link);

      if (options.type === 'tag') {
        this.triggerTagChange({ slug: options.tag_slug });
      } else if (options.type === 'more') {
        this.triggerMoreChange();
      }
    }
  };


  Pulldown.prototype.changeActiveLink = function (link) {
    if (this.activeLink) {
      this.activeLink.removeClass('active');
    }
    this.activeLink = link;
    link.addClass('active');
  };


  Pulldown.prototype.fetchData = function (options) {
    if (this.cachedData[options.cache_key]) {
      options.callback.call(this, this.cachedData[options.cache_key]);
    } else {
      $.get(options.url, $.proxy(function (data) {
        options.callback.call(this, data);
        this.cachedData[options.cache_key] = data;
      }, this));
    }
  };


  Pulldown.prototype.triggerTagChange = function (options) {
    this.fetchData({
      url: Pulldown.urls.tag_highlights(options.slug),
      cache_key: 'tag-' + options.slug,
      callback: function (data) {
        this.updateItems(data);
      }
    });
  };


  Pulldown.prototype.triggerMoreChange = function () {
    this.fetchData({
      url: Pulldown.urls.more,
      cache_key: 'more',
      callback: function (data) {
        this.updateItems(data);
      }
    });
  };


  /**
   * Inspect current state and calls showItems/hideItems as needed.
   */
  Pulldown.prototype.updateItems = function (newData) {
    var expand, collapse;

    expand = !this.currentData;
    collapse = this.currentData &&
      (newData.type === this.currentData.type &&
       ((newData.type === 'tag' && newData.tag.slug === this.currentData.tag.slug)
        || newData.type === 'more'));

    if (expand) {
      this.expand($.proxy(function () {
        this.createShowAll(newData);
        this.showItems(newData);
      }, this));
    } else if (collapse) {
      this.removeShowAll();
      this.items.animate({ top: '-320px' }, {
        complete: $.proxy(function () {
          this.loading(false);
          this.items.remove();
          this.items = this.currentData = null;
        }, this)
      });
      this.collapse($.proxy(function () {
        this.resetActiveLink();
      }, this));
    } else {
      this.showItems(newData, true);
      this.updateShowAll(newData);
    }
  };


  /**
   * Expands the pulldown menu
   */
  Pulldown.prototype.expand = function (cb) {
    this.pulldown.animate({ height: '306px' }, { complete: cb, duration: 200 });
  };


  /**
   * Collapses the pulldown menu
   */
  Pulldown.prototype.collapse = function (cb) {
    this.pulldown.animate({ height: '0' }, { complete: cb, duration: 200 });
  };


  /**
   * Shows the highlight items with a specific animation. Async calls
   * callback param after finishing.
   */
  Pulldown.prototype.showItems = function (data, hidePrev) {
    var oldItems, getAnimParams, newItems, that;

    that = this;

    getAnimParams = function (cb) {
      return { easing: 'easeOutBounce', duration: 600, complete: cb };
    };

    oldItems = this.items;
    if (data.type === 'tag') {
      newItems = this.createTagItems(data);
    } else {
      newItems = this.createMoreItems(data);
    }
    newItems.animate({ top: '0px' }, getAnimParams(function () {
      that.loading(false);
    }));

    if (hidePrev) {
      oldItems.animate({ top: '306px' }, getAnimParams(function () {
        oldItems.remove();
      }));
    }

    this.items = newItems;
    this.currentData = data;
  };


  /**
   * Returns the markup (jquery object) for the given the highlight json.
   */
  Pulldown.prototype.createTagItems = function (data) {
    var items, blockedItemIdx, li, ul, sliderCls, newItems;

    ul = $('<ul class="items"/>');
    items = $('#tagHighlightsItemTemplate').tmpl(data.highlights);
    sliderCls = 'tag-highlights-slider';

    if (this.blockItems) {
      // random item from the first 4.
      blockedItemIdx = Math.floor(Math.random() * 4);

      items.each($.proxy(function (i, el) {
        li = (i === blockedItemIdx) ? this.getBlockedItem() : $(el);
        ul.append(li);
      }, this));

    } else {
      ul.append(items);
    }

    ul
      .appendTo(this.pulldown)
      .multislider({
        cls: sliderCls,
        carouselOptions: {
          items: { visible: 4 },
          scroll: {
            items: 4,
            duration: 900,
            easing: 'quadratic'
          },
          auto: false
        }
      });
    newItems = ul.parents('.' + sliderCls);
    newItems.append('<a href=""></a>');

    return newItems;
  };


  Pulldown.prototype.createMoreItems = function (data) {
    return $('<ul class="more-items"/>')
      .append($('#moreItemTemplate').tmpl(data.categories))
      .appendTo(this.pulldown);
  };


  /**
   * Create and return a blocked item element.
   */
  Pulldown.prototype.getBlockedItem = function () {
    return $('#tagHighlightsBlockedItemTemplate')
      .tmpl()
      .find('.btn').click(function (e) {
        e.preventDefault();
        ajaxSignup.signUp();
      })
      .end();
  };


  // This (and the ul wrapper) should be defined in a template
  Pulldown.prototype.createShowAll = function (newData) {
    this.showMore = $('<div class="wrapper pulldown_show_more"><a href="#"></a></div>').hide();
    this.pulldown.parent().after(this.showMore);
    this.updateShowAll(newData);
  };


  Pulldown.prototype.updateShowAll = function (newData) {
    this.showMore.fadeOut($.proxy(function () {
      var link;

      link = this.showMore.children();
      if (newData.type === 'tag') {
        link.html('Show all "<strong>' + newData.tag.name + '</strong>" plans &raquo;');
        link.attr('href', newData.tag.url);
      } else {
        link.html('Show <strong>all plans</strong> &raquo;');
        link.attr('href', Pulldown.urls.everything);
      }
      this.showMore.fadeIn();
    }, this));
  };


  Pulldown.prototype.removeShowAll = function () {
    this.showMore.fadeOut(200);
  };


  Pulldown.prototype.resetActiveLink = function () {
    this.activeLink.removeClass('active');
    this.activeLink = null;
  };


  Pulldown.prototype.loading = function (isLoading) {
    this.loadingContent = isLoading;
    this.links.animate({ 'opacity': isLoading ? '.5' : '1' }, 'fast');
  };


  Pulldown.prototype.isLoading = function () {
    return this.loadingContent;
  };

  return new Pulldown();
});
