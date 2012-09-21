require(['jquery', 'backbone'], function () {

  var R = Backbone.Router.extend({

    routes: {
      'welcome' : 'showWelcome',
      'setup': 'showSetup',
      'marketing-configuration': 'showMarketingConfiguration',
      'service-area': 'showServiceArea',
      'fullfilment-assistance': 'showFullfilmentAssistance',
      'first-plan': 'showFirstPlan',
      '*uri': 'showListBusiness'
    },

    showListBusiness: function () {
      require(['layout', 'list_business'], function (layout, ListBusiness) {
        layout.setView(new ListBusiness());
      });
    },

    showWelcome: function () {
      require(['layout', 'welcome'], function (layout, Welcome) {
        layout.setView(new Welcome());
      });
    },

    showSetup: function () {
      require(['layout', 'setup'], function (layout, Setup) {
        layout.setView(new Setup());
      });
    },

    showMarketingConfiguration: function () {
      require(['layout', 'marketing_configuration'], function (layout, MarketingConfiguration) {
        layout.setView(new MarketingConfiguration());
      });
    },

    showServiceArea: function () {
      require(['layout', 'service_area'], function (layout, ServiceArea) {
        layout.setView(new ServiceArea());
      });
    },

    showFullfilmentAssistance: function () {
      require(['layout', 'fullfilment_assistance'], function (layout, FullfilmentAssistance) {
        layout.setView(new FullfilmentAssistance());
      });
    },

    showFirstPlan: function () {
      require(['layout', 'first_plan'], function (layout, FirstPlan) {
        layout.setView(new FirstPlan());
      });
    }

  });

  window.router = new R();

  Backbone.history.start();

});