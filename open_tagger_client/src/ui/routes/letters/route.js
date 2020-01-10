import Route from '@ember/routing/route';

export default class LettersRoute extends Route {
//   model() {
//     return this.store.query('letter', { items: 100 }).then(results => {
//       return {
//         letters: results,
//         meta: results.meta
//       };
//     });
//   }

  setupController(controller/*, { letters, meta }*/) {
    this._super(controller/*, letters*/);
    // controller.set('letters', letters);
    // controller.set('meta', meta);
    this.store.findAll('letter-date').then(dates => {
      controller.set('letterDates', dates.firstObject);
      controller.set('minStartDate', dates.firstObject.min);
      controller.set('maxEndDate', dates.firstObject.max);
    })
  }
}
