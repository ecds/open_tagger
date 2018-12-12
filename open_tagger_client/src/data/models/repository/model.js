import DS from 'ember-data';
const {
  Model,
  attr,
  hasMany
} = DS;

export default Model.extend({
  label: attr('string'),
  letters: hasMany('letters'),
  collections: hasMany('collection')
});
