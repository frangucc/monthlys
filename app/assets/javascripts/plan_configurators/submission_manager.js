/*jslint indent: 2*/
/*global define*/
define(['jquery'], function ($) {
  'use strict';

  function SubmissionManager(states, callback) {
    this.stateKeys = states;
    this.callback = callback;
    this.states = {};
    this.reset();
  }

  SubmissionManager.prototype.reset = function () {
    var i;
    for (i = 0; i < this.stateKeys.length; i += 1) {
      this.states[this.stateKeys[i]] = false;
    }
  };

  SubmissionManager.prototype.hasFinished = function () {
    var i;
    for (i = 0; i < this.stateKeys.length; i += 1) {
      if (!this.states[this.stateKeys[i]]) {
        return false;
      }
    }
    return true;
  };

  SubmissionManager.prototype.deleteStateKey = function (state) {
    this.stateKeys = $.grep(this.stateKeys, function (v) {
      return v !== state;
    });
  };

  SubmissionManager.prototype.done = function (state, remove) {
    if ($.inArray(state, this.stateKeys) === -1) {
      return;
    }
    this.states[state] = true;
    if (remove) {
      this.deleteStateKey(state);
    }

    if (this.callback && this.hasFinished()) {
      this.callback();
    }
  };

  return SubmissionManager;
});
