import Controller from '@ember/controller';
import { action } from '@ember-decorators/object';
import { A } from '@ember/array';
import { task, timeout, waitForProperty } from 'ember-concurrency';

export default class EntitiesController extends Controller {
  // TODO maybe make this a restartable task? Probably not helpful.
  @action
  updateProperty(key, content) {
    content = content.replace(/<div>/g, '');
    content = content.replace(/<\/div>/g, '');
    this.tagToEdit.properties.set(key, content);
  }
}