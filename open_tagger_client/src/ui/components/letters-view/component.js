import Component from '@ember/component';
import {
  tagName
} from '@ember-decorators/component';
// import UIkit from 'uikit';

@tagName('pre')
export default class LettersView extends Component {
  didInsertElement() {
    this.element.innerHTML = this.letter.content;
  }

  mouseUp(event) {
    if (event.target.tagName !== 'PRE') return;
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

  contextMenu(event) {
    // console.log(event.target.tagName);
    if (event.target.tagName === 'PRE') return;
    event.preventDefault();
    this.showContextMenu(event);
    return false;
  }

  // TODO set tooltip!
  // mouseMove(event) {
  //   if (event.target.tagName === 'PRE') return;
  //   event.target.setAttribute('uk-tooltip', 'oh hello');
  //   UIkit.tooltip(event.target).show();
  // }

  click(event) {
    if (event.target.tagName === 'PRE') return;
    this.editTag(event);
  }
}
