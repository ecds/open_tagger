import DS from 'ember-data';
const {
  Model,
  attr,
  hasMany
} = DS;

export default Model.extend({
  'title_en': attr('string'),
  letters: hasMany('letters'),
  literals: hasMany('literal'),
  wikidata_id: attr('string'),
  label: attr('string'),
  description: attr('string')
});
