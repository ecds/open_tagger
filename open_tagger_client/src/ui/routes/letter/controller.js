import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { A } from '@ember/array';
import { task, timeout, waitForProperty } from 'ember-concurrency';

export default class LettersLetterController extends Controller {
  results = this.results || A([]);
  wikiResults = this.wikiResults || A([]);
  selectedText = this.selectedText || null;
  queryText = this.selectedText || null;
  newLiteral = this.newLiteral || null;
  matches = this.matches || A([]);
  selectedType = this.selectedType || null;
  letterContent = this.letterContent || null;
  // modal = this.modal || null;
  // new = this.new || null;
  tagToEdit = this.tagToEdit || null;
  literalToEdit = this.literalToEdit || null;
  tagElementToEdit = this.tagElementToEdit || null;

  editorOptions = {
    actions: [
      'bold',
      'italic',
      'underline'
    ]
  }

  flagEntity = task(function * () {
    let unknownEntity = yield this.store.createRecord('entity', {
      entityType: this.selectedType,
      suggestion: ''
    });
    yield unknownEntity.save();
    yield waitForProperty(unknownEntity, 'id', v => v != null);
    if (!this.newLiteral) {
      let unknownLiteral = yield this.store.createRecord('literal', {
        text: this.selectedText,
        entity: unknownEntity
      });
      unknownLiteral.save();
      yield waitForProperty(unknownLiteral, 'id', v => v != null);
      this.set('newLiteral', unknownLiteral);
    }
    this.newLiteral.setProperties({
      review: true
    });
    yield this.get('addLiteral').perform(unknownEntity);
    this.clear();
  })

  addLiteral = task(function * (entity) {
    if (this.newLiteral === null) {
      let newLiteral = yield this.store.createRecord('literal', {
        text: this.selectedText
      });
      this.set('newLiteral', newLiteral);
    }
    this.newLiteral.setProperties({
      entity: entity,
      review: true
    });
    // yield this.newLiteral.save();
    // yield waitForProperty(this.newLiteral, 'id', v => v != null);
    this.model.letter.get('literals').pushObject(this.newLiteral);
    yield this.get('tagEntity').perform(entity);
  })

  suggestNewEntity = task(function * () {
    let newEntity = yield this.store.createRecord('entity', {
      suggestion: this.selectedText,
      entityType: this.selectedType
    });
    this.set('newEntity', newEntity);
    yield waitForProperty(newEntity, 'id', v => v != null);
    yield this.get('addLiteral').perform(newEntity);
    yield this.set('newEntity', newEntity);
  })
  
  saveSuggestion = task(function * () {
    yield this.newEntity.save();
    yield this.get('addLiteral').perform(this.newEntity);
    this.set('newEntity', null);
    this.clear();
  })

  scrubLetter() {
    let content = document.getElementsByTagName('pre')[0].innerHTML;
    content = content.replace(/<text>/g, '');
    content = content.replace(/<\/text>/g, '');
    content = content.replace(/<tmp>/g, '');
    content = content.replace(/<\/tmp>/g, '');
    document.getElementsByTagName('pre')[0].innerHTML = content;
    return content;
  }
  
  updateLetter = task(function * () {
    const content = document.getElementsByTagName('pre')[0].innerHTML;
    yield timeout(300);
    this.model.letter.setProperties({
      content
    });
    yield this.model.letter.save();
    document.getElementsByTagName('pre')[0].innerHTML = content;
  })

  updateTag = task(function * () {
    this.tagToEdit.set('entityType', this.selectedType);
    yield this.tagToEdit.save();
    yield this.get('tagEntity').perform(this.tagToEdit);
    this.send('reset');
  })

  tagEntity = task(function * (entity) {
    if (entity.id == null) return;
    let elementToTag = document.querySelector('tmp');
    if (!elementToTag) {
      elementToTag = this.tagElementToEdit;
    }
    if (elementToTag) {
      if (!elementToTag.parentNode) return;
      let newElement = document.createElement(this.selectedType.get('label').toLocaleLowerCase().dasherize());
      if(entity.suggestion || !entity.label) {
        newElement.classList.add('flag');
      }
      yield timeout(300);
      newElement.setAttribute('profile_id', entity.id);
      yield timeout(300);
      newElement.innerHTML = elementToTag.innerHTML
      elementToTag.parentNode.replaceChild(newElement, elementToTag);
    }
    yield timeout(300);
    yield this.get('updateLetter').perform();
    this.clear();
  })

  clear() {
    this.set('newLiteral', null);
    this.set('newEntity', null);
    this.set('selectedText', null);
    this.set('queryText', null);
    this.set('selectedType', null);
    this.set('tagToEdit', null);
    this.set('literalToEdit', null);
    this.send('clearResults');
    window.getSelection().empty();
  }

  unTagEntity = task(function * () {
    const content = this.scrubLetter();
    this.model.letter.setProperties({
      content
    });
    yield timeout(10);
    yield this.model.letter.get('literals').removeObject(this.literalToEdit);
    yield this.model.letter.save();
    this.clear();
  })
  
  addExistingLiteral = task(function * (literal) {
    this.set('newLiteral', literal);
    let entity = yield literal.get('entity')
      // this.get('addLiteral').perform(entity);
    this.model.letter.get('literals').pushObject(literal);
    this.get('tagEntity').perform(entity);
  })

  editTag = task(function * (event) {
    document.getSelection().removeAllRanges();
    try {
      let tagToEdit = yield this.store.findRecord('entity', event.target.attributes.profile_id.value);
      const literalToEdit = yield this.store.queryRecord('literal', {text: event.target.innerText, type: tagToEdit.entityType.getProperties('label').label});
      this.set('tagElementToEdit', event.target);
      this.set('tagToEdit', tagToEdit);
      this.set('literalToEdit', literalToEdit);
      this.set('selectedText', literalToEdit.text);
    } catch(error) {
      console.log(error);
    }
  })

  @action
  setLetterContent(content) {
    this.set('letterContent', content);
  }

  // First we do a text search for possible entities.
  // If none are found, we get suggestions from WikiData (currently commented out).
  @action
  search() {
    this.store.query('entity', {
      query: this.queryText,
      type: this.selectedType.get('label')
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
      content
    });
    this.model.letter.save();
  }

  @action
  setSelected(selection, element) {
    if (this.selectedText) return;
    this.clear();
    this.set('tagElementToEdit', element);
    this.set('selectedText', selection);
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
    // this.get('closeContextMenu').perform();
    this.send('clearResults');
    this.store.query('literal', {
      text: this.queryText,
      type: this.selectedType.label,
      search: true
    }).then(literals => {
      if (literals.firstObject.unassigned) {
        this.set('newLiteral', literals.firstObject);
      } else {
        this.set('matches', literals);
      }
      this.send('search');
    });
  }


  @action
  cancel() {
    this.send('reset');
  }
  
  @action
  reset() {
    this.get('unTagEntity').perform();
  }

  @action
  clearResults() {
    this.set('results', A([]));
    this.set('matches', A([]));
  }

  // @action
  // associateRepo(repo) {
  //   let repos = this.newLetter.get('repositories');
  //   repos.pushObject(repo);
  // }

  // @action
  // createRepo(label) {
  //   let newRepo = this.store.createRecord('repository', {
  //     label
  //   });
  //   newRepo.save().then(repo => {
  //     this.send('associateRepo', repo);
  //   })
  // }

  // @action
  // associateCollection(collection) {
  //   let collections = this.newLetter.get('collections');
  //   collections.pushObject(collection);
  // }

  // @action
  // createCollection(repo, label) {
  //   let newCollection = this.store.createRecord('collection', {
  //     label,
  //     repository: repo
  //   });
  //   newCollection.save().then(collection => {
  //     let collections = repo.get('collections')
  //     collections.pushObject(collection);
  //     repo.save();
  //     this.send('associateCollection', collection);
  //   })
  // }

  @action
  removeTag() {
    if (!this.tagElementToEdit) return;
    if (!this.tagElementToEdit.parentElement) return
    let newEl = document.createElement('text');
    newEl.innerText = this.tagElementToEdit.innerText;
    this.tagElementToEdit.parentElement.replaceChild(
      newEl,
      this.tagElementToEdit
    );
    this.get('unTagEntity').perform();
  }
}
