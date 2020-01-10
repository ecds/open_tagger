import Component from '@ember/component';
import { tagName } from '@ember-decorators/component';


@tagName('pre')
export default class LettersView extends Component {
  contenteditable = this.contenteditable;
  letterElements = ['PRE', 'CONTENT', 'LETTER', 'METADATA'];
  attributeBindings = ['contenteditable'];
  
  didInsertElement() {
    this.element.innerHTML = this.letter.content;
  }

  mouseUp(event) {
    console.log(event)
    if (this.element.contains(document.getElementsByTagName('tmp')[0])) return;
    if (this.contenteditable) return;
    if (this.letterElements.includes(event.target.tagName) || this.letterElements.includes(event.target.parentElement.tagName)) {
      let selected = document.getSelection();
      let tmpEl = document.createElement('tmp');
      if (document.getSelection().type !== 'Range') return;
      if (selected.rangeCount) {
        let range = selected.getRangeAt(0).cloneRange();
        range.surroundContents(tmpEl);
        selected.removeAllRanges();
        selected.addRange(range);
      }
      // Call action passed in from controller.
      this.select(selected.toString(), tmpEl);
    }
  }

  click(event) {
    if (event.target.tagName === 'PRE') return;
    if (event.target.tagName === 'CONTENT') return;
    if (document.getSelection().type == 'Range') return;
    if (this.contenteditable) return;
    this.editTag(event);
  }
}
