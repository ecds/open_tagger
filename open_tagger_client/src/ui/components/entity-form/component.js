import Component from '@ember/component';
import { task } from 'ember-concurrency';
import { action } from '@ember-decorators/object';

export default class EntityFormComponent extends Component {
  @action
  updateArrayItem(obj, property, index, value) {
    obj[property][index] = value
  }

  addToArrayProp = task(function * (property) {
    this.entity.properties[property].push('');
    let update = this.entity.properties[property]
    let newAtrs = []
    update.forEach(item => {
      newAtrs.push(item)
    })
    this.entity.set(`properties.${property}`, newAtrs);
  })

  @action
  addToObjectProp(parent, obj, property) {
    // console.log(parent)
    // console.log(property)
    // console.log(obj)
    let newObj = {};
    Object.keys(obj.firstObject).forEach(key => {
      newObj[key] = ''
    })
    obj.push(newObj);
    let grrr = [];
    obj.forEach(o => {
      grrr.push(o)
    });
    console.log(grrr)
    this.entity.set(`properties.${parent}.${property}`, grrr)
  }
}
