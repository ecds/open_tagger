import Component from '@ember/component';
import { action } from '@ember-decorators/object';

export default class LetterWrapperComponent extends Component {
  classList = this.typeList();
  showAll = true;

  typeList() {
    let list = [];
    this.entityTypes.forEach(type => {
      if (type.show) {
        list.push(type.label);
      }
    });
    if (list.length != this.entityTypes.length) {
      this.set('showAll', false);
    }
    return list.join(' ');
  }

  @action
  toggleTag() {
    this.set('classList', this.typeList());
  }

  @action
  toggleAll() {
    this.set('showAll', !this.showAll);
    this.entityTypes.forEach(type => {
      type.setProperties({show: this.showAll});
    });
    this.set('classList', this.typeList());
  }
}
