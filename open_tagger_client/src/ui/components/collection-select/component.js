import Component from '@ember/component';
import { computed } from '@ember-decorators/object';
import { tagName } from '@ember-decorators/component';

@tagName('span')
export default class CollectionSelectComponent extends Component {

  repo = this.repo || null;
  letter = this.letter || null;

  @computed('repo', 'letter.collections')
  get selectedCollection() {
    let intersection = this.repo.get('collections').filter( c => {
      return this.letter.get('collections').includes(c)
    });
    return intersection.firstObject
  }
}
