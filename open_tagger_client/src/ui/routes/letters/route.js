import Route from '@ember/routing/route';

export default class LettersRoute extends Route {
  model() {
    return this.store.findAll('letter');
  }

}
