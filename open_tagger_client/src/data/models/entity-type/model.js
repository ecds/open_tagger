import DS from 'ember-data';
import { computed } from '@ember/object';
import { pluralize } from 'ember-inflector';
const { Model, attr, hasMany } = DS;

export default Model.extend({
  label: attr('string'),
  'pretty_label': attr('string'),
  entities: hasMany('entity'),
  'property-labels': hasMany('property-label'),
  friendlyLabel: computed('label', function() {
    return this.label.toLocaleLowerCase().dasherize();
  }),
  show: attr('boolean', { defaultValue: true } ),
  plural: computed('label', function() {
    return pluralize(this.pretty_label);
  })
});
