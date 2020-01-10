import Route from '@ember/routing/route';

export default class EntitiesEntityRoute extends Route {
  model(params) {
    return this.store.findRecord('entity', params.entity_id)
  }
}
