import Component from '@ember/component';
import UIkit from 'uikit';

const noop = () => {};

export default Component.extend({
  attributeBindings: ['ukModal:uk-modal', 'id'],
  modalName: 'uk-dialog',
  id: 'entity-modal',

  // Component Options
  escClose: true,
  bgClose: true,
  stack: false,
  container: false,
  clsPage: null,
  clsPanel: null,
  selClose: null,
  center: false,
  full: false,
  overflowAuto: false,

  setEvents() {
    let events = {
      beforeshow: this.getWithDefault('on-beforeshow', noop),
      show: this.getWithDefault('on-show', noop),
      shown: this.getWithDefault('on-shown', noop),
      beforehide: this.getWithDefault('on-beforehide', noop),
      hide: this.getWithDefault('on-hide', noop),
      hidden: this.getWithDefault('on-hidden', noop)
    };

    for (let event in events) {
      UIkit.util.on(this.element, event, events[event]);
    }
  },

  didInsertElement() {
    this._super(...arguments);
    const modal = UIkit.modal(this.element)
    this.setEvents();
    this.set('modal', modal);
  }
});
