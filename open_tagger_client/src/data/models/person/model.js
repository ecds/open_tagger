import DS from 'ember-data';
const {
  Model,
  attr,
  hasMany
} = DS;

export default Model.extend({
  label: attr('string'),
  literals: hasMany('literal'),
  notes: attr('string'),
  'wikidata-id': attr('string')
});
