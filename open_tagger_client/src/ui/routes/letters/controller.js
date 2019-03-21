import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { alias, sort, filterBy, mapBy } from '@ember/object/computed';

export default class LettersController extends Controller {
  tableClassNames = 'uk-table uk-table-striped'

  letters = alias('model');
  byDateSorting = Object.freeze(['date_sent:asc']);
  byDate = sort('letters', 'byDateSorting');

  @action
  onRowSingleClick(letter) {
    this.transitionToRoute('letter', letter.id);
  }
}
