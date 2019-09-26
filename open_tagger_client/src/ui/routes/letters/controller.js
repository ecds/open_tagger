import Controller from '@ember/controller';
import { action, computed } from '@ember-decorators/object';
import { sort } from '@ember/object/computed';
import { inject as service } from '@ember/service';

export default class LettersController extends Controller {
  store = service();
  tableClassNames = 'uk-table uk-table-striped';
  startDate = null;
  endDate = null;
  autoCompleteEmpty = true;
  recipientFilter = null;

  // letters = alias('model');
  byDateSorting = Object.freeze(['date_sent:asc']);
  byDate = sort('letters', 'byDateSorting');
  currentPage = 1;

  fetchData() {
    this.get('store').query('letter', { page: this.currentPage }).then(letters => {
      this.set('letters', letters);
      this.setNextPages();
    });
    // this.get('store').findAll('letter-date').then(dates => {
    //   this.set('letterDates', dates)
    // })
  }

  nextPages = Array.from({length:5},(v,k)=>k+parseInt(this.currentPage + 1));

  setNextPages() {
    this.set('nextPages', Array.from({length:5},(v,k)=>k+parseInt(this.currentPage + 1)));
  }

  @computed('meta')
  get lastPage() {
    return this.meta.pagination['total-pages'];
  }

  @action
  filterRecipients(selection) {
    this.set('recipientFilter', selection);
    this.get('store').query('letter', {
      recipients: this.recipientFilter,
      start: this.startDate,
      end: this.endDate
    }).then(letters => {
      this.set('letters', letters);
    });
  }

  @action
  clearRecipientsFilter() {
    this.get('store').query('letter', {
      start: this.startDate,
      end: this.endDate
    }).then(letters => {
      this.set('letters', letters);
    });
  }

  @action
  enableAutoComplete() {
    this.set('autoCompleteEmpty', false);
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
  jumpToPage(page) {
    this.set('currentPage', parseInt(page));
    this.fetchData();
  }

  @action
  selectionChanged(selectedRows){
    this.set('selectedRows', selectedRows);
  }

  @action
  fetchRange(extent, date) {
    if (extent == 'min') {
      this.set('startDate', date);
    } else if (extent == 'max') {
      this.set('endDate', date)
    }
    this.get('store').query('letter', {
      recipients: this.recipientFilter,
      start: this.startDate,
      end: this.endDate
    }).then(letters => {
      this.set('letters', letters);
    })
  }

  @action
  resetStart(event) {
    let min = this.store.peekAll('letter-date').firstObject.min;
    event.target.previousElementSibling.firstElementChild.value = `${min.getDate()}.${min.getMonth()}.${min.getFullYear()}`;
    this.fetchRange('min', min)
  }

  @action
  resetEnd() {
    let max = this.store.peekAll('letter-date').firstObject.max;
    event.target.previousElementSibling.firstElementChild.value = `${max.getDate()}.${max.getMonth()}.${max.getFullYear()}`;
    this.selectionChanged('fetchRange', 'max', max)
  }
}
