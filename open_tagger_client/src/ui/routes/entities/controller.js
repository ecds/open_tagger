import Controller from '@ember/controller';
import { action, computed } from '@ember-decorators/object';
import { task } from 'ember-concurrency';
import { inject as service } from '@ember/service';

export default class EntitiesController extends Controller {
  
  store = service();
  searchResults = false;

  saveEntity = task(function * (entity) {
    yield entity.save();
    this.set('rowIndexToShowDetail', null);
  })

  @action
  updateProperty(key, content) {
    content = content.replace(/<div>/g, '');
    content = content.replace(/<\/div>/g, '');
    this.tagToEdit.properties.set(key, content);
  }

  @action
  toggleDetail(rowIndex, entity) {
    // entity.set('showDetail', !entity.showDetail);
    if (this.get('rowIndexToShowDetail')===rowIndex) {
      this.discardDetail();
    } else {
      this.set('rowIndexToShowDetail', rowIndex);
      // this.set('newNickToSet', this.get('data')[rowIndex].nick);
    }
  }

  @action
  toggleEntityDetail(entity) {
    entity.set('showDetail', true);
  }

  discardDetail() {
    this.set('rowIndexToShowDetail', null);
  }

  search = task(function * () {
    let results = yield this.get('store').query('entity', {
      query: this.queryText,
      type: this.entityType,
      items: 100
    });
    if (results.length > 0) {
      this.set('entities', results);
      this.set('meta', results.meta);
      this.set('searchResults', true);
    }
  })

  clearSearch = task(function * () {
    this.set('queryText', '');
    let results = yield this.get('store').query('entity', { type: this.entityType, items: 100 });
    this.set('entities', results);
    this.set('meta', results.meta);
    this.set('searchResults', false);
  })

  @action
  searchOnEnter() {
    if (this.queryText == '') {
      this.get('clearSearch').perform();
    } else {
      this.get('search').perform();
    }
  }
  // Pagination

  currentPage = 1;

  fetchData() {
    this.get('store').query('entity', { page: this.currentPage, entity_type: this.entityType }).then(entities => {
      this.set('entities', entities);
      this.setNextPages();
    });
  }

  nextPages = Array.from({length:5},(v,k)=>k+parseInt(this.currentPage + 1));

  setNextPages() {
    this.set('nextPages', Array.from({length:5},(v,k)=>k+parseInt(this.currentPage + 1)).filter(page => page < this.get('lastPage')));
  }

  @computed('meta')
  get lastPage() {
    return this.meta.pagination['total-pages'];
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
}