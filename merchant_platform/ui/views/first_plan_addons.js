define('first_plan_addons', 
  ['wizard_nav', 'wizard_title', 'wizard_forms', 'jquery', 'jqueryui', 'backbone'],
  function (WizardNav, WizardTitle, WizardForms) {

    var FirstPlanAddons = Backbone.View.extend({

      template: null,

      initialize: function () {
        this.template = _.template($('#templates .first_plan_addons').html());
        this.render();
      },

      render: function () {
        this.$el.html(this.template());
        new WizardNav({
          el: this.$el.find('.wizard_nav'),
          onBack: function () {

          },
          onNext: function () {

          }
        });
        new WizardTitle({
          el: this.$el.find('.wizard_title'),
          heading: 'Plan Options',
          paragraph: 'If you have addons to your plans, you need to provide your customers with questions and answers, so they can choose what they want.'
        });
        new QuestionList({
          el: this.$el.find('.first_plan_addons_question_list')
        });
      }

    });

    var QuestionList = Backbone.View.extend({

      items: null,

      events: {
        'click .add_question': 'onAddClick',
        'click .handle': 'onHandleClick'
      },

      initialize: function () {
        this.items = [];
        this.render();
      },

      render: function () {
        this.$el.html($('#templates .first_plan_addons_question_list').html());
      },

      /**
       * When the add button is clicked, a new item is added to the list.
       */
      onAddClick: function () {
        var question = new QuestionListItem({
          el: $('<li />'),
          onExpand: $.proxy(this.onExpandItem, this)
        });
        this.$el.find('.questions')
          .append(question.$el)
          .sortable({
            handle: '.handle'
          });
        this.items.push(question);
        question.expand();
        return false;
      },

      onHandleClick: function () {
        return false;
      },

      onExpandItem: function (expanded) {
        $(this.items).each(function (i, obj) {
          obj.collapse();
        });
      }

    });

    var QuestionListItem = Backbone.View.extend({

      answers: null,

      expanded: false,

      events: {
        'click': 'onClick',
        'click .arrow': 'onClickArrow',
        'click .remove_question': 'onClickRemove'
      },

      initialize: function () {
        this.render();
      },

      render: function () {
        this.$el.html($('#templates .first_plan_addons_question_list_item').html());
        this.answers = new AnswerList({
          el: this.$el.find('.first_plan_addons_answer_list')
        });
        new WizardForms.SelectField({
          el: this.$el.find('select')
        });
      },

      collapse: function () {
        this.$el.addClass('collapsed');
        this.expanded = false;
      },

      expand: function () {
        this.options.onExpand(this);
        this.$el.removeClass('collapsed');
        this.expanded = true;
      },

      toggleExpand: function () {
        this.expanded ? this.collapse() : this.expand();
      },

      onClick: function () {
        this.expand();
      },

      onClickArrow: function () {
        this.toggleExpand();
        return false;
      },

      onClickRemove: function () {
        this.$el.remove();
        return false;
      }

    });

    var AnswerList = Backbone.View.extend({

      items: null,

      events: {
        'click .add_answer': 'onAddClick',
        'click .handle': 'onHandleClick'
      },

      initialize: function () {
        this.items = [];
        this.render();
      },

      render: function () {
        this.$el.html($('#templates .first_plan_addons_answer_list').html());
      },

      onAddClick: function () {
        var answer = new AnswerListItem({
          el: $('<li />'),
          onExpand: $.proxy(this.onExpandItem, this)
        });
        this.$el.find('.answers')
          .append(answer.$el)
          .sortable({
            handle: '.handle'
          });
        this.items.push(answer);
        answer.expand();
        return false;
      },

      onHandleClick: function () {
        return false;
      },

      onExpandItem: function () {
        $(this.items).each(function (i, obj) {
          obj.collapse();
        });
      }

    });

    var AnswerListItem = Backbone.View.extend({

      events: {
        'click': 'onClick',
        'click .remove_answer': 'onClickRemove'
      },

      initialize: function () {
        this.render();
      },

      render: function () {
        this.$el.html($('#templates .first_plan_addons_answer_list_item').html());
      },

      collapse: function () {
        this.$el.addClass('collapsed');
      },

      expand: function () {
        this.options.onExpand();
        this.$el.removeClass('collapsed');
      },

      onClick: function () {
        this.expand();
      },

      onClickRemove: function () {
        this.$el.remove();
        return false;
      }

    });

    return FirstPlanAddons;

  }
);