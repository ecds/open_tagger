import Component from '@ember/component';
import { tagName } from '@ember-decorators/component';

@tagName('pre')
export default class LettersView extends Component {

  didInsertElement() {
    this.element.innerHTML = this.letter.content;
  }

  mouseUp() {
    if (this.element.contains(document.getElementsByTagName('tmp')[0])) return;
    let selected = document.getSelection();
    let tmpEl = document.createElement('tmp')
    if (document.getSelection().type !== 'Range') return;
    if (selected.rangeCount) {
      let range = selected.getRangeAt(0).cloneRange();
      range.surroundContents(tmpEl);
      selected.removeAllRanges();
      selected.addRange(range);
    }
    // Call action passed in from controller.
    this.select(selected.toString());
  }
}
