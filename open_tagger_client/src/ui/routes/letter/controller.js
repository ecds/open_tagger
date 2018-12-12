import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { A } from '@ember/array';
import { task } from 'ember-concurrency';
// import $ from 'jquery';
// import UIkit from 'uikit';

export default class LettersLetterController extends Controller {
  results = this.results || A([]);
  wikiResults = this.wikiResults || A([]);
  queryText = this.queryText || null;
  newLiteral = this.newLiteral || null;
  matches = this.matches || A([]);
  // selected = this.selected || null;
  selectedType = this.selectedType || null;
  letterContent = this.letterContent || null;
  modal = this.modal || null;
  new = this.new || null;

  flagEntity = task(function * () {
    let unknownEntity = yield this.store.queryRecord('entity', {
      query: 'unknown',
      type: this.selectedType.label
    });
    this.get('newLiteral').setProperties({ review: true });
    yield this.get('addLiteral').perform(unknownEntity)
    this.send('tagEntity', unknownEntity);
  })

  addLiteral = task(function * (entity) {
    this.get('newLiteral').set('entity', entity);
    yield this.newLiteral.save();
    return true;
  })

  @action
  setLetterContent(content) {
    this.set('letterContent', content);
  }

  // First we do a text search for possible entities.
  // If none are found, we get suggestions from WikiData.
  search() {
    this.store.query('entity', {
      query: this.queryText,
      type: this.selectedType.label
    }).then(results => {
      if (results.length > 0) {
        this.set('results', results);
      } //else {
      //   $.ajax({
      //     url: '//www.wikidata.org/w/api.php',
      //     data: {
      //       action: 'wbsearchentities',
      //       search: this.newLiteral.text,
      //       format: 'json',
      //       language: 'en',
      //       uselang: 'en',
      //       type: 'item',
      //     },
      //     dataType: 'jsonp',
      //     success: result => {
      //       this.set('wikiResults', result.search);
      //     }
      //   });
      // }
    });
  }

  @action
  setLetter(content) {
    this.model.letter.setProperties({
      content: content
    });
    this.model.letter.save();
  }

  @action
  setSelected(selection) {
    if (this.queryText) return;
    this.set('queryText', selection);
  }

  @action
  setType(event) {
    this.set(
      'selectedType',
      this.store.peekRecord('entity_type', event.target.value)
    );
    this.send('getLiteral');
  }

  // The API creates a new literal if a match is not found.
  // The new literal will be "unassigned" meaning it does not
  // have a canonical entity.
  @action
  getLiteral() {
    this.send('clearResults');
    this.store.query('literal', {
      text: this.queryText,
      type: this.selectedType.label
    }).then(literals => {
      if (literals.firstObject.unassigned) {
        this.set('newLiteral', literals.firstObject);
      } else {
        this.set('matches', literals);
      }
      this.search();
    });
  }

  // @action
  // assocEntity(entity) {
  //   this.newLiteral.set('entity', entity);
  //   this.newLiteral.save().then(() => {
  //     this.send('tagEntity', entity);
  //   })
  // }

  // @action
  // newFromWD(wdResult) {
  //   let newEntity = this.store.createRecord('entity', {
  //     wikidata_id: wdResult.id,
  //     entity_type: this.selectedType
  //   });
  //   this.send('addLiteral', newEntity).then(() => {
  //     this.send('tagEntity', newEntity);
  //   }, () => {
  //     // error
  //   })
  // }

  @action
  flagEntity() {
    this.store.queryRecord('entity', {
      query: 'unknown',
      type: this.selectedType.label
    }).then((unknownEntity) => {
      this.newLiteral.setProperties({ review: true });
      this.send('addLiteral', unknownEntity);
    });
  }
  
  @action
  suggestNewEntity() {
    this.send('clearResults');
    let newEntity = this.store.createRecord('entity', {
      label: this.queryText,
      entity_type: this.selectedType
    });
    this.get('addLiteral').perform(newEntity).then(() => {
      this.set('newEntity', newEntity);
    })
  }

  @action
  addExistingLiteral(literal) {
    this.set('newLiteral', literal);
    literal.get('entity').then((entity) => {
      this.send('addLiteral', entity);
    })
  }
  
  @action
  addLiteral(entity) {
    this.newLiteral.set('entity', entity)
    this.newLiteral.save().then(() => {
      this.send('tagEntity', entity);
    });
  }

  @action
  saveSuggestion() {
    this.newEntity.save().then(() => {
      this.get('addLiteral').perform(this.newEntity).then(() => {
        this.send('tagEntity', this.newEntity);
      });
    })
  }

  @action
  cancel() {
    this.send('reset');
  }
  
  @action
  reset() {
    this.send('unTagEntity');
    this.set('newLiteral', null);
    this.set('newEntity', null);
    this.set('queryText', null);
    this.set('selectedType', null);
    this.send('clearResults');
    window.getSelection().empty();
  }

  @action
  clearResults() {
    this.set('results', A([]));
    this.set('matches', A([]));
  }

  @action
  tagEntity(entity) {
    let tmpElement = document.querySelector('tmp');
    let newElement = document.createElement(this.selectedType.label.toLocaleLowerCase().dasherize());
    newElement.setAttribute('profile_id', entity.id);
    newElement.innerHTML = tmpElement.innerHTML
    tmpElement.parentNode.replaceChild(newElement, tmpElement);
    this.model.letter.setProperties({
      content: document.getElementsByTagName('pre')[0].innerHTML
    });
    this.model.letter.save().then(() => {
      this.send('reset');
    });
  }

  @action
  unTagEntity() {
    this.model.letter.setProperties({
      content: this.model.letter.content.replace(/<tmp>/g, '')
    });
    this.model.letter.setProperties({
      content: this.model.letter.content.replace(/<\/tmp>/g, '')
    });
  }

  @action
  associateRepo(repo) {
    let repos = this.newLetter.get('repositories');
    repos.pushObject(repo);
  }

  @action
  createRepo(label) {
    let newRepo = this.store.createRecord('repository', {
      label
    });
    newRepo.save().then(repo => {
      this.send('associateRepo', repo);
    })
  }

  @action
  associateCollection(collection) {
    let collections = this.newLetter.get('collections');
    collections.pushObject(collection);
  }

  @action
  createCollection(repo, label) {
    let newCollection = this.store.createRecord('collection', {
      label,
      repository: repo
    });
    newCollection.save().then(collection => {
      let collections = repo.get('collections')
      collections.pushObject(collection);
      repo.save();
      this.send('associateCollection', collection);
    })
  }
}
