import DS from 'ember-data';
const {
  Model,
  attr,
  hasMany,
  belongsTo
} = DS;

export default Model.extend({
  label: attr('string'),
  literals: hasMany('literal'),
  entityType: belongsTo('entity-type'),
  suggestion: attr('string'),
  letters: hasMany('letter')
});
