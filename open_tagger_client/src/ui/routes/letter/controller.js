import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { A } from '@ember/array';
import { task, timeout, waitForProperty } from 'ember-concurrency';
import UIkit from 'uikit';

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
  editLetter = this.emptyId || false;
  tagTags = ['directing', 'revision', 'star'];
  tagTagsToAdd = this.tagTagsToAdd || [];

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
    yield this.get('scrubLetter').perform();
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
    document.querySelector(`[profile_id="${entity.id}"]`).classList.remove('flag');
    yield this.get('updateLetter').perform();
    this.set('tagToEdit', null);
    this.clear();
  })

  scrubLetter = task(function * () {
    let highlights = document.querySelectorAll(`[class*="highlight"]`);
    highlights.forEach(function(el) { el.classList.remove('highlight') });
    let content = document.getElementsByTagName('pre')[0].innerHTML;
    content = content.replace(/<text>/g, '');
    content = content.replace(/<\/text>/g, '');
    content = content.replace(/<tmp>/g, '');
    content = content.replace(/<\/tmp>/g, '');
    document.getElementsByTagName('pre')[0].innerHTML = content;
    yield timeout(300);
    return content;
  })

  updateLetter = task(function * () {
    const originalContent = this.model.letter.content;
    const content = yield this.get('scrubLetter').perform();
    yield timeout(300);

    // if ((originalContent.length - 100) > content.length) {
    //   yield UIkit.modal.alert('It looks like this will clear the contents of this letter. It\'s not your fault, it\'s Jay\'s. Please let him know which letter and what you were trying to do.');
    //   this.model.letter.setProperties({
    //     content: originalContent
    //   });
    //   document.getElementsByTagName('pre')[0].innerHTML = originalContent;
    // } else {
      this.model.letter.setProperties({
        content
      });
      document.getElementsByTagName('pre')[0].innerHTML = content;
      yield this.model.letter.save();
    // }

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
      let newElement = document.createElement(this.selectedType.get('label')); //.toLocaleLowerCase().dasherize());
      if(entity.suggestion || entity.flagged) {
        newElement.classList.add('flag');
      }
      newElement.setAttribute('profile_id', entity.id);
      newElement.innerHTML = elementToTag.innerHTML
      yield this.tagTagsToAdd.forEach(tagTag => {
        newElement.setAttribute(tagTag, true);
      })
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
    this.set('emptyId', false);
    this.set('tagToEdit', null);
    this.send('clearResults');
    window.getSelection().empty();
  }

  saveEntity = task(function * (entity) {
    yield entity.save();
    yield this.get('updateLetter').perform();
    this.clear();
  })

  deleteEntity = task(function * (entity) {
    const entityToDelete = yield this.store.peekRecord('entity', entity.id);
    entityToDelete.destroyRecord();
    // yield entityToDelete.save();
  })

  unTagEntity = task(function * () {
    const content = yield this.get('scrubLetter').perform();
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
    yield this.get('scrubLetter').perform();
    yield this.get('updateLetter').perform();
    this.clear();
})

  editTag = task(function * (event) {
    document.getSelection().removeAllRanges();
    this.set('tagTagsToAdd', []);
    if (event.target.attributes.profile_id && event.target.attributes.profile_id.value != '') {
      yield this.tagTags.forEach(tag => {
        if (event.target.attributes[tag]) {
          this.tagTagsToAdd.push(tag);
        }
      });
      try {
        this.set('selectedText', event.target.innerText);
        let tagToEdit = yield this.store.peekRecord('entity', event.target.attributes.profile_id.value);
        if (tagToEdit == null) {
          this.set('emptyId', true);
          this.set('selectedText', null);
        }
        this.set('tagElementToEdit', event.target);
        this.set('tagToEdit', tagToEdit);
      } catch(error) {
        // console.log(error, event.target);
      }
    } else {
      // let type = yield this.store.queryRecord('entity_type', { label: event.target.tagName.toLowerCase()})
      // this.set('selectedType', type);
      this.set('tagElementToEdit', event.target);
      // this.set('queryText', event.target.innerText);
      // yield this.get('search').perform();
      this.set('emptyId', true);
    }
  })

  deleteTag = task(function * (entity) {
    let tag = document.querySelector(`[profile_id="${entity.id}"]`);
    let tagToEdit = yield this.store.peekRecord('entity', entity.id);
    this.set('tagToEdit', tagToEdit)
    if (tag) {
      this.set('tagElementToEdit', tag);
      this.send('removeTag');
    } else {
      this.get('unTagEntity').perform();
    }
  })

  @action
  collectExtraAttrs(event) {
    const target = event.target;
    if (target.checked) {
      this.tagTagsToAdd.push(target.id);
      if (this.tagElementToEdit) {
        this.tagElementToEdit.setAttribute(target.id, true);
      }
    }
    else if (
      this.tagTagsToAdd.includes(target.id)
      && !target.checked
    ) {
      this.tagTagsToAdd.splice(
        this.tagTagsToAdd.indexOf(target.id),
        1
      );
      if (this.tagElementToEdit) {
        this.tagElementToEdit.removeAttribute(target.id)
      }
    }
  }

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
    this.get('scrubLetter').perform();
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
    if (this.emptyId) {
      this.clear();
      this.get('updateLetter').perform();
    } else {
      this.get('unTagEntity').perform();
    }
  }
}
