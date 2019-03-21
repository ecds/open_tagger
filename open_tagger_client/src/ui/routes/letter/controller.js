import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { A } from '@ember/array';
import { task, timeout } from 'ember-concurrency';

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
  tagToEdit = this.tagToEdit || null;
  literalToEdit = this.literalToEdit || null;
  tagElementToEdit = this.tagElementToEdit || null;

  flagEntity = task(function * () {
    let unknownEntity = yield this.store.createRecord('entity', {
      entityType: this.selectedType,
      suggestion: ''
    });
    // yield unknownEntity.save();
    this.newLiteral.setProperties({
      review: true
    });
    yield this.get('addLiteral').perform(unknownEntity)
  })

  addLiteral = task(function * (entity) {
    if (this.newLiteral === null) {
      let newLiteral = yield this.store.createRecord('literal', {
        text: this.queryText
      });
      this.set('newLiteral', newLiteral);
    }
    this.newLiteral.setProperties({
      entity: entity,
      review: true
    });
    yield this.newLiteral.save();
    this.get('tagEntity').perform(entity);
  })

  suggestNewEntity = task(function * () {
    let newEntity = yield this.store.createRecord('entity', {
      label: this.queryText,
      entityType: this.selectedType
    });
    this.set('newEntity', newEntity);
    // this.get('addLiteral').perform(newEntity).then(() => {
      //   this.set('newEntity', newEntity);
      // })
    this.send('clearResults');
  })

  saveSuggestion = task(function * () {
    yield this.newEntity.save();
    yield this.get('addLiteral').perform(this.newEntity);
  })

  scrubLetter() {
    let content = document.getElementsByTagName('pre')[0].innerHTML;
    content = content.replace(/<text>/g, '');
    content = content.replace(/<\/text>/g, '');
    content = content.replace(/<tmp>/g, '');
    content = content.replace(/<\/tmp>/g, '');
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

  updateEntity = task(function * () {
    // this.send('removeTag');
    // yield timeout(300);
    this.tagToEdit.setProperties({
      entity_type: this.selectedType
    });
    yield this.get('tagEntity').perform(this.tagToEdit);
    yield this.tagToEdit.save();
  })

  tagEntity = task(function * (entity) {
    let elementToTag = document.querySelector('tmp');
    if (!elementToTag) {
      elementToTag = this.tagElementToEdit;
    }
    if (elementToTag) {
      let newElement = document.createElement(this.selectedType.label.toLocaleLowerCase().dasherize());
      if(entity.suggestion) {
        newElement.classList.add('flag');
      }
      yield timeout(300);
      newElement.setAttribute('profile_id', entity.id);
      yield timeout(300);
      newElement.innerHTML = elementToTag.innerHTML
      elementToTag.parentNode.replaceChild(newElement, elementToTag);
    }
    yield timeout(300);
    this.model.letter.get('entities').pushObject(entity);
    yield this.get('updateLetter').perform();
    this.send('reset');
  })

  unTagEntity = task(function * () {
    const content = this.scrubLetter();
    this.model.letter.setProperties({
      content
    });
    document.getElementsByTagName('pre')[0].innerHTML = content;
    yield timeout(10);
    yield this.model.letter.save();
  })

  editTag = task(function * (event) {
    document.getSelection().removeAllRanges();
    try {
      let tagToEdit = yield this.store.findRecord('entity', event.target.attributes.profile_id.value);
      const literalToEdit = yield this.store.queryRecord('literal', {text: event.target.innerText, type: tagToEdit.entityType.getProperties('label').label});
      this.set('tagElementToEdit', event.target);
      this.set('tagToEdit', tagToEdit);
      this.set('literalToEdit', literalToEdit);
      this.set('queryText', literalToEdit.text);
      this.set('selectedType', tagToEdit.entityType.getProperties('label'));
      this.send('getLiteral');
    } catch(error) {
      console.log(error);
    }
  })

  // showContextMenu = task(function * (event) {
  //   document.getSelection().removeAllRanges();
  //   try {
      // let tagToEdit = yield this.store.findRecord('entity', event.target.attributes.profile_id.value);
  //     this.set('tagElementToEdit', event.target);
  //     let literalToEdit = this.store.queryRecord('literal', {text: event.target.innerText, type: tagToEdit.entityType.getProperties('label').label});
      // this.set('tagToEdit', tagToEdit);
  //     this.set('literalToEdit', literalToEdit);
  //     console.log(tagToEdit.entityType.getProperties('label'));
      // this.set('selectedType', tagToEdit.entityType.getProperties('label'));
  //     let editCard = document.getElementById('edit-card');
  //     let top = event.originalEvent.clientY + 20;
  //     let left = event.originalEvent.clientX;
  //     let windowWidth = document.body.clientWidth;
  //     if ((left + 300) > windowWidth) {
  //       left = windowWidth - 350;
  //     }
  //     let position = `top: ${top}px; left: ${left}px;`;
  //     editCard.style.cssText = position; 
  //   } catch(e) {
  //     //
  //   }
  // })

  @action
  setLetterContent(content) {
    this.set('letterContent', content);
  }

  showTooltip(event) {
    console.log(event);
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
      content
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
    if (this.tagToEdit) {
      this.tagToEdit.setProperties({
        entityType: this.selectedType
      });
    }
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
      this.search();
    });
  }

  @action
  addExistingLiteral(literal) {
    this.set('newLiteral', literal);
    literal.get('entity').then((entity) => {
      this.get('addLiteral').perform(entity);
    })
  }

  @action
  cancel() {
    this.send('reset');
  }
  
  @action
  reset() {
    this.get('unTagEntity').perform();
    this.set('newLiteral', null);
    this.set('newEntity', null);
    this.set('queryText', null);
    this.set('selectedType', null);
    this.set('tagElementToEdit', event.target);
    this.set('tagToEdit', null);
    this.set('literalToEdit', null);
    this.send('clearResults');
    window.getSelection().empty();
  }

  @action
  clearResults() {
    this.set('results', A([]));
    this.set('matches', A([]));
  }

  // @action
  // tagEntity(entity) {
  //   let tmpElement = document.querySelector('tmp');
  //   let newElement = document.createElement(this.selectedType.label.toLocaleLowerCase().dasherize());
  //   newElement.setAttribute('profile_id', entity.id);
  //   newElement.innerHTML = tmpElement.innerHTML
  //   tmpElement.parentNode.replaceChild(newElement, tmpElement);
  //   // let content = document.getElementsByTagName('pre')[0].innerHTML;
  //   // console.log(content);
  //   // this.model.letter.setProperties({
  //   //   content: '.'
  //   // });
  //   // this.model.letter.setProperties({
  //   //   content
  //   // });
  //   this.model.letter.save().then(() => {
  //     this.send('reset');
  //   });
  // }
  

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

  @action
  removeTag() {
    if (!this.tagElementToEdit) return;
    let newEl = document.createElement('text');
    newEl.innerText = this.tagElementToEdit.innerText;
    this.tagElementToEdit.parentElement.replaceChild(
      newEl,
      this.tagElementToEdit
    );
    // this.get('closeContextMenu').perform();
    this.get('unTagEntity').perform();
  }

  closeContextMenu = task(function * () {
    let editCard = document.getElementById('edit-card');
    editCard.removeAttribute('style');
    this.set('tagToEdit', null);
    this.set('tagElementToEdit', null);
    document.getSelection().removeAllRanges();
    yield timeout(300);
    yield this.get('updateLetter').perform();
  })
}
