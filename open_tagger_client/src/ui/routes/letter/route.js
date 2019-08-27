import Route from '@ember/routing/route';
import RSVP from 'rsvp';
import { action } from '@ember-decorators/object';

export default class LettersLetterRoute extends Route {
  afterModel() {
    window.scrollTo(0,0)
  }

  model(params) {
    // return this.store.findAll('entity');
    return RSVP.hash({
      letter: this.store.findRecord('letter', params.letter_id),
      entityTypes: this.store.findAll('entity_type'),
      repos: this.store.findAll('repository')
    });
  }

  setupController(controller, model) {
    this._super(controller, model);
    this.controllerFor('letter').set('store', this.store);
    this.controllerFor('letter').set('model', model);
  }

  @action
  didTransition() {
    this.controllerFor('letter').clear();
  }
}
