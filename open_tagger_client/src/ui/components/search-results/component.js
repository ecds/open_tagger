import Component from '@ember/component';
import { action } from '@ember-decorators/object';
import UIkit from 'uikit';

export default class SearchResultsComponent extends Component {
  @action
  confirmDelete(result) {
    UIkit.modal.confirm(`Are you sure you want to delete: ${result.label}`).then( () => {
      this.deleteEntity.perform(result);
    }, () => {
      // nothing
    });
  }
}
