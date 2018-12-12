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
  entity_type: belongsTo('entity_type'),
  suggestion: attr('string')
});
