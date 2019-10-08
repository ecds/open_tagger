import Route from '@ember/routing/route';
import { singularize } from 'ember-inflector';

export default class EntitiesRoute extends Route {
  model(params) {
    return this.store.query('entity', { entity_type: singularize(params.entity_type), items: 100 }).then(results => {
      return {
        entities: results,
        meta: results.meta,
        type: params.entity_type
      };
    });
  }

  setupController(controller, { entities, meta, type }) {
    this._super(controller, entities);
    controller.set('entities', entities);
    controller.set('entityType', type);
    controller.set('meta', meta);
  }
} 
