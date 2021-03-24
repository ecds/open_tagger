import Component from '@ember/component';
import UIkit from 'uikit';

export default class ConfirmModalComponent extends Component {
  didInsertElement() {
    UIkit.util.on(this.element)
  }
}
