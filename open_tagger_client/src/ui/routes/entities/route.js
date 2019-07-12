import Route from '@ember/routing/route';

export default class EntitiesRoute extends Route {
  model(params) {
    return this.store.query('entity', { entity_type: params.entity_type });
  }
} 
