import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { sort } from '@ember/object/computed';
import { inject as service } from '@ember/service';

export default class LettersController extends Controller {
  store = service();
  tableClassNames = 'uk-table uk-table-striped';

  // letters = alias('model');
  byDateSorting = Object.freeze(['date_sent:asc']);
  byDate = sort('letters', 'byDateSorting');
  currentPage = 1;

  fetchData() {
    this.get('store').query('letter', { page: this.currentPage }).then(letters => {
      this.set('letters', letters);
    });
  }

  @action
  onRowSingleClick(letter) {
    this.transitionToRoute('letter', letter.id);
  }

  @action
  nextPageRequested() {
    this.incrementProperty('currentPage');
    this.fetchData();
  }

  @action
  prevPageRequested() {
      this.decrementProperty('currentPage');
      this.fetchData();
    }

  @action
  selectionChanged(selectedRows){
      this.set('selectedRows', selectedRows);
    }
}
