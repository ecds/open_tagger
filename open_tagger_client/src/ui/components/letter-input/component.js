import Component from '@ember/component';
// import UIkit from 'uikit';

export default class LetterInputComponent extends Component {
  attributeBindings = ['contenteditable'];
  contenteditable = true;
  modal = null;

  click() {
    this.set('clicked', true);
  }

  paste() {
    window.setTimeout(() => {
      const pastedText = `${this.element.innerText}`;
      this.set('contenteditable', false);
      this.element.innerHTML = null;
      // Call action passed in from controller.
      this.setLetter(pastedText);
    });
  }

  // didInsertElement() {
  //   this.set(
  //     'modal',
  //     UIkit.modal(document.getElementById('modal-center'))
  //   );
  // }
}
