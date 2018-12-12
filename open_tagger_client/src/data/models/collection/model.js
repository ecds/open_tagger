import DS from 'ember-data';
const { Model, attr, belongsTo, hasMany } = DS;

export default Model.extend({
  label: attr('string'),
  repository: belongsTo('repository'),
  letters: hasMany('letter')
});
