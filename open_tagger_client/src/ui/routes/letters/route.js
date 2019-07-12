import Route from '@ember/routing/route';

export default class LettersRoute extends Route {
  model() {
    return this.store.query('letter', {}).then(results => {
      return {
        letters: results,
        meta: results.meta
      };
    });
  }

  setupController(controller, { letters, meta }) {
    this._super(controller, letters);
    controller.set('letters', letters);
    controller.set('meta', meta);
  }
}
