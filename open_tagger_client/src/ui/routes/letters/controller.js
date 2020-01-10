import Controller from '@ember/controller';
import { action, computed } from '@ember-decorators/object';
import { sort } from '@ember/object/computed';
import { inject as service } from '@ember/service';
import { task, waitForProperty } from 'ember-concurrency';

export default class LettersController extends Controller {
  store = service();
  queryParams = ['start', 'end', 'recipients', 'page', 'items', 'flaggedOnly'];
  start = null;
  end = null;
  recipients = null;
  page = null;
  items = this.items || 100;
  tableClassNames = 'uk-table uk-table-striped';
  startDate = null;
  endDate = null;
  autoCompleteEmpty = true;
  recipients = null;
  letterDates = {};
  flaggedOnly = false;

  itemValues = [10, 25, 50, 100, 150, 200];

  // letters = alias('model');
  byDateSorting = Object.freeze(['date_sent:asc']);
  byDate = sort('letters', 'byDateSorting');
  currentPage = 1;

  fetchData = task(function * () {
    this.set('letters', null);
    yield waitForProperty(this, 'maxEndDate');
    if (this.start != null) {
      let dateParts = this.start.split('.');
      this.set('startDate', `${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`);
    } else if (this.minStartDate) {
      this.set('startDate', this.minStartDate);
    }
    if (this.end != null) {
      let dateParts = this.end.split('.');
      this.set('endDate', `${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`);
    } else if (this.maxEndDate) {
      this.set('endDate', this.maxEndDate);
    }
    if (this.recipients != null) {
      this.set('recipients', this.recipients)
    }
    if (this.page != null) {
      this.set('currentPage', this.page);
    }
    let letters = yield this.get('store').query(
      'letter',
      {
        page: this.currentPage,
        recipients: this.recipients,
        items: this.items,
        start: this.startDate,
        end: this.end,
        flagged: this.flaggedOnly
      });
    this.set('letters', letters);
    this.set('meta', letters.meta)
    this.setNextPages();
  }).restartable()

  nextPages = Array.from({length:5},(v,k)=>k+parseInt(this.currentPage + 1));

  setNextPages() {
    this.set('nextPages', Array.from({length:5},(v,k)=>k+parseInt(this.currentPage + 1)).filter(page => page < this.get('lastPage')));
  }

  @computed('meta')
  get lastPage() {
    return this.meta.pagination['total-pages'];
  }

  @computed('meta')
  get resultPages() {
    return Array.from({length:parseInt(this.meta.pagination['total-pages'])},(v,k)=>k+1)
  }

  @computed('model', 'start', 'end', 'recipients', 'page', 'items')
  get filteredLetters() {
    this.get('fetchData').perform();
  }

  @computed('page')
  get currentPageInt() {
    return parseInt(this.page);
  }

  @action
  filterRecipients(selection) {
    this.set('recipients', selection);
    this.get('fetchData').perform();
  }

  @action
  clearRecipientsFilter() {
    document.getElementById('autoComplete').value = null
    this.set('recipients', null);
    this.get('fetchData').perform();
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
    this.set('page', this.currentPage);
    this.get('fetchData').perform();
  }

  @action
  prevPageRequested() {
    this.decrementProperty('currentPage');
    this.set('page', this.currentPage);
    this.get('fetchData').perform();
  }

  @action
  jumpToPage(page) {
    console.log("TCL: LettersController -> jumpToPage -> page", page)
    this.set('currentPage', parseInt(page));
    this.set('page', parseInt(page));
    this.get('fetchData').perform();
  }

  @action
  selectionChanged(selectedRows){
    this.set('selectedRows', selectedRows);
  }

  @action
  fetchRange(extent, date) {
    if (!date) return;
    // date = this.formatDate(date);
    if (extent == 'min') {
      // this.set('startDate', date);
      this.set('start', document.getElementById('start-date-field').value);
    } else if (extent == 'max') {
      // this.set('end', date);
      this.set('end', document.getElementById('end-date-field').value);
      // this.set('end', date);
    }
    this.get('fetchData').perform();
    // this.get('store').query('letter', {
    //   recipients: this.recipients,
    //   start: this.startDate,
    //   end: this.endDate
    // }).then(letters => {
    //   this.set('letters', letters);
    //   this.set('meta', letters.meta);
    //   this.setNextPages();
   // })
  }

  @action
  toggleFlagged(event) {
    if (event.target.checked) {
      this.set('flaggedOnly', true);
    } else {
      this.set('flaggedOnly', false);
    }
    this.get('fetchData').perform();
  }

  formatDate(date) {
    return `${date.getDate()}.${date.getMonth()}.${date.getFullYear()}`
  }

  @action
  resetStart() {
    let min = this.store.peekAll('letter-date').firstObject.min;
    // event.target.previousElementSibling.firstElementChild.value = this.formatDate(min);
    this.set('startDate', min);
    this.set('start', this.formatDate(min))
    this.get('fetchData').perform();
    // this.fetchRange('min', min)
  }
  
  @action
  resetEnd() {
    let max = this.store.peekAll('letter-date').firstObject.max;
    // event.target.previousElementSibling.firstElementChild.value = this.formatDate(max);
    this.set('endDate', max);
    this.set('end', this.formatDate(max))
    this.get('fetchData').perform();
    // this.selectionChanged('fetchRange', 'max', max)
  }

  @action
  setItems(count) {
    this.set('items', count);
  }
}
