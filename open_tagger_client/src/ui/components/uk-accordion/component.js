import Component from '@ember/component';
import { tagName } from '@ember-decorators/component';
import UIkit from 'uikit';

@tagName('ul')
export default class UkAccordionComponent extends Component {
  attributeBindings = ['ukAccordion:uk-accordion'];
  tagEl = null;

  ukAccordion = true;

  didInsertElement() {
    UIkit.util.on(`#${this.element.id}`, 'beforeshow', () => {
      let openEntities = document.getElementsByClassName('uk-open')
      for (let openEntity of openEntities) {
        let parent = openEntity.parentElement;
        if (parent != this.element) {
          UIkit.accordion(`#${parent.id}`).toggle();
        }
      }
    });

    UIkit.util.on(`#${this.element.id}`, 'show', () => {
      let tagId = document.getElementsByClassName('uk-open')[0].id;
      let tag = document.querySelectorAll(`[profile_id="${tagId}"]`);
      console.log(tag)
      if (tag.length > 0) {
        this.set('tagEl', tag[0]);
        this.tagEl.classList.add('highlight');
      } else {
        UIkit.modal.alert('Tag not found in letter :(');
      }
    });

    UIkit.util.on(`#${this.element.id}`, 'beforehide', () => {
      if (this.tagEl) {
        // let tag = document.querySelectorAll(`[profile_id="${this.tagId}"]`);
        this.tagEl.classList.remove('highlight');
      }
    });
  }
}
