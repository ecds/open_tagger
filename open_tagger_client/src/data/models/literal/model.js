import DS from 'ember-data';
const {
  Model,
  attr,
  belongsTo
} = DS;

export default Model.extend({
  text: attr('string'),
  unassigned: attr('boolean'),
  review: attr('boolean'),
  entity: belongsTo('entity')
});
