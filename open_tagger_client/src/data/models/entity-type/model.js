import DS from 'ember-data';
import { computed } from '@ember/object';
const { Model, attr, hasMany } = DS;

export default Model.extend({
  label: attr('string'),
  entities: hasMany('entity'),
  'property-labels': hasMany('property-label'),
  friendlyLabel: computed('label', function() {
    return this.label.toLocaleLowerCase().dasherize();
  })
});
