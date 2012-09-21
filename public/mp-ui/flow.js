/**
 * Controller defines the whole flow of the wizard.
 * Creates instances of each view as needed and gives
 * the correct handlers to each one.
 * @author    Federico Bana <federico.bana@monthlys.com>
 */
require(
  [
    'welcome', 'setup_assistance', 'custom_url', 'marketing_configuration',
    'create_plan', 'plan_list', 'storefront_index', 'storefront_content',
    'storefront_service_area', 'storefront_fullfilment_assistance',
    'review_settings'
  ],
  /**
   * Called right after all the dependencies are loaded.
   * @param   WelcomeView   -> first form in the flow
   * @param   SetupAssistanceView   -> user asked for assistance and its still pending
   * @param   MarketingConfigurationView -> select marketing options
   * @param   FirstPlanView -> create first plan
   * @param   PlanListView -> review plans and create more plans
   * @param   StorefrontIndexView -> basic info about business
   * @param   StorefrontContentView -> multimedia content about business
   * @param   StorefrontServiceAreaView -> business' service area info
   * @param   StorefrontFullfilmentAssistanceView -> ask for assistance
   * @param   ReviewSettingsView -> review and correct
   */
  function (WelcomeView, SetupAssistanceView, CustomUrlView,
      MarketingConfigurationView, CreatePlanView, PlanListView, 
      StorefrontIndexView, StorefrontContentView, StorefrontServiceAreaView,
      StorefrontFullfilmentAssistanceView, ReviewSettingsView) {

    var welcome, setupAssistance, customUrl, marketingConfig, firstPlan,
        createPlan, planList, storefrontIndex, storefrontContent,
        storefrontServiceArea, storefrontFullfilmentAssistance, reviewSettings;

    // First step: welcome message
    welcome = new WelcomeView({
      onContinue: function (view) {
        // Choose which way to go based on selection.
        if (view.noAssistance()) {
          // "No assistance" goes to "custom URL" wizard.
          switchToView(customUrl);
        }
        else {
          // "Setup assistance" goes to a "wait" message.
          switchToView(setupAssistance);
        }
      }
    });

    // Second step: custom url.
    customUrl = new CustomUrlView({
      onContinue: function (view) {
        switchToView(marketingConfig);
      }
    });

    // Second step (no assistance): setup assistance.
    setupAssistance = new SetupAssistanceView({
      onBack: function (view) {
        switchToView(welcome);
      }
    });

    // Third step: marketing configuration.
    marketingConfig = new MarketingConfigurationView({
      onContinue: function (view) {
        switchToView(firstPlan);
      }
    });

    // Fourth step: create first plan.
    firstPlan = new CreatePlanView({
      first: true,
      onContinue: function (view) {
        switchToView(planList);
      }
    });

    // Fourth step (another plan): create another plan.
    createPlan = new CreatePlanView({
      first: false,
      onContinue: function (view) {
        switchToView(planList);
      }
    });

    // Fifth step: review plans.
    planList = new PlanListView({
      onCreatePlan: function () {
        switchToView(createPlan);
      },
      onContinue: function () {
        switchToView(storefrontIndex);
      }
    });

    // Sixth step: store basic information.
    storefrontIndex = new StorefrontIndexView({
      onContinue: function (view) {
        switchToView(storefrontContent);
      }
    });

    // Seventh step: store content media.
    storefrontContent = new StorefrontContentView({
      onContinue: function (view) {
        switchToView(storefrontServiceArea);
      }
    });

    // Eighth step: area of service.
    storefrontServiceArea = new StorefrontServiceAreaView({
      onContinue: function (view) {
        switchToView(storefrontFullfilmentAssistance);
      }
    });

    // Nineth step: need assistance on store fullfilment?
    storefrontFullfilmentAssistance = new StorefrontFullfilmentAssistanceView({
      onContinue: function (view) {
        switchToView(reviewSettings);
      }
    });

    // Last step: review.
    reviewSettings = new ReviewSettingsView({
      onBack: function () {
        switchToView(storefrontFullfilmentAssistance);
      }
    });

    // Add all steps to DOM tree.
    $('#application')
      .append(welcome.$el)
      .append(setupAssistance.$el)
      .append(customUrl.$el)
      .append(marketingConfig.$el)
      .append(firstPlan.$el)
      .append(createPlan.$el)
      .append(planList.$el)
      .append(storefrontIndex.$el)
      .append(storefrontContent.$el)
      .append(storefrontServiceArea.$el)
      .append(storefrontFullfilmentAssistance.$el)
      .append(reviewSettings.$el);

    // Show first view
    switchToView(createPlan);

    /**
     * Hides all the views and shows only the view passed in the param.
     * @param   view    -> shows this view alone.
     */
    function switchToView(view) {
      // Hide all views before displaying the one its switching to
      welcome ? welcome.$el.hide() : false;
      setupAssistance ? setupAssistance.$el.hide() : false;
      customUrl ? customUrl.$el.hide() : false;
      marketingConfig ? marketingConfig.$el.hide() : false;
      firstPlan ? firstPlan.$el.hide() : false;
      createPlan ? createPlan.$el.hide() : false;
      planList ? planList.$el.hide() : false;
      storefrontIndex ? storefrontIndex.$el.hide() : false;
      storefrontContent ? storefrontContent.$el.hide() : false;
      storefrontServiceArea ? storefrontServiceArea.$el.hide(): false;
      storefrontFullfilmentAssistance ? storefrontFullfilmentAssistance.$el.hide() : false;
      reviewSettings ? reviewSettings.$el.hide() : false;
      view ? view.$el.show() : false;
    }

  }
);