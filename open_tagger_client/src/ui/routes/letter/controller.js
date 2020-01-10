import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { A } from '@ember/array';
import { task, timeout, waitForProperty } from 'ember-concurrency';

export default class LettersLetterController extends Controller {
  results = this.results || A([]);
  wikiResults = this.wikiResults || A([]);
  selectedText = this.selectedText || null;
  queryText = this.selectedText || null;
  matches = this.matches || A([]);
  selectedType = this.selectedType || null;
  letterContent = this.letterContent || null;
  tagToEdit = this.tagToEdit || null;
  tagElementToEdit = this.tagElementToEdit || null;
  editLetter = this.contenteditable || false;

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
      flagged: true,
      label: this.selectedText
    });
    yield unknownEntity.save();
    yield waitForProperty(unknownEntity, 'id', v => v != null);
    yield this.get('tagExistingEntity').perform(unknownEntity);
    this.clear();
    this.scrubLetter();
  })

  suggestNewEntity = task(function * () {
    let newEntity = yield this.store.createRecord('entity', {
      suggestion: this.selectedText,
      entityType: this.selectedType,
      flagged: true,
      label: this.selectedText,
      properties: {}
    });
    this.set('newEntity', newEntity);
    yield waitForProperty(newEntity, 'id', v => v != null);
    this.set('newEntity', newEntity);
    yield this.get('tagExistingEntity').perform(newEntity);
  })
  
  saveSuggestion = task(function * () {
    yield this.newEntity.save();
    this.set('newEntity', null);
    this.clear();
  })

  unFlag = task(function * (entity) {
    entity.setProperties({
      flagged: false
    });
    yield entity.save();
    document.querySelector(`[profile_id="${entity.id}"]`).classList.remove('flag')
    yield this.get('updateLetter').perform();
    this.set('tagToEdit', null);
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
    this.set('editLetter', false);
  })

  updateTag = task(function * () {
    this.tagToEdit.set('entityType', this.selectedType);
    yield this.tagToEdit.save();
    yield this.get('tagEntity').perform(this.tagToEdit);
    yield this.get('updateLetter').perform();
    this.clear();
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
      if(entity.suggestion || entity.flagged) {
        newElement.classList.add('flag');
      }
      newElement.setAttribute('profile_id', entity.id);
      newElement.innerHTML = elementToTag.innerHTML
      if (!elementToTag.parentNode) return;
      elementToTag.parentNode.replaceChild(newElement, elementToTag);
    }
    yield timeout(300);
  }).restartable()

  clear() {
    this.set('newEntity', null);
    this.set('selectedText', null);
    this.set('queryText', null);
    this.set('selectedType', null);
    this.set('tagToEdit', null);
    this.send('clearResults');
    window.getSelection().empty();
  }

  unTagEntity = task(function * () {
    const content = this.scrubLetter();
    this.model.letter.setProperties({
      content
    });
    yield timeout(10);
    yield this.model.letter.get('entities_mentioned').removeObject(this.tagToEdit);
    yield this.tagToEdit.save();
    yield this.model.letter.save();
    this.clear();
  })
  
  tagExistingEntity = task(function * (entity) {
    yield this.get('tagEntity').perform(entity);
    this.model.letter.get('entities_mentioned').pushObject(entity);
    yield this.model.letter.save();
    entity.get('letters').pushObject(this.model.letter);
    yield entity.save();
    this.scrubLetter();
    yield this.get('updateLetter').perform();
    this.clear();
})

  editTag = task(function * (event) {
    document.getSelection().removeAllRanges();
    try {
      let tagToEdit = yield this.store.peekRecord('entity', event.target.attributes.profile_id.value);
      this.set('tagElementToEdit', event.target);
      this.set('tagToEdit', tagToEdit);
      this.set('selectedText', event.target.innerText);
    } catch(error) {
      console.log(error, event.target);
    }
  })

  @action
  setLetterContent(content) {
    this.set('letterContent', content);
  }

  search = task(function * () {
    let results = yield this.store.query('entity', {
      search: this.queryText,
      entity_type: this.selectedType.get('label')
    });
    if (results.length > 0) {
      this.set('results', results);
    }
  })

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
    this.get('search').perform();
  }

  @action
  searchOnEnter() {
    this.get('search').perform();
  }

  @action
  cancel() {
    this.send('reset');
  }
  
  @action
  reset() {
    this.clear();
    this.scrubLetter();
  }

  @action
  clearResults() {
    this.set('results', A([]));
    this.set('matches', A([]));
  }

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
