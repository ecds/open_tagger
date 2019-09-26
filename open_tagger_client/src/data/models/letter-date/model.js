import DS from 'ember-data';
const { Model, attr } = DS;

export default Model.extend({
  min: attr('date'),
  max: attr('date')
});