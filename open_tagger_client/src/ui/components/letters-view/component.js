import Component from '@ember/component';
import { tagName } from '@ember-decorators/component';

@tagName('pre')
export default class LettersView extends Component {

  mouseUp() {
    let selected = document.getSelection();
    console.log(selected);
    let tmpEl = document.createElement('tmp')
    if (document.getSelection().type !== 'Range') return;
    if (selected.rangeCount) {
      let range = selected.getRangeAt(0).cloneRange();
      console.log(range);
      range.surroundContents(tmpEl);
      selected.removeAllRanges();
      selected.addRange(range);
      this.letter.setProperties({
        content: this.element.innerHTML
      });
    }
    // Call action passed in from controller.
    this.select(selected.toString());
  }
}
