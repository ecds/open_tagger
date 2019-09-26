import DS from 'ember-data';
import { computed } from '@ember/object';

const {
  Model,
  attr,
  belongsTo,
  hasMany
} = DS;

export default Model.extend({
  code: attr('string'),
  content: attr('string'),
  date: attr('date'),
  month: attr('number'),
  year: attr('number'),
  recipient_list: attr('string'),
  legacy_pk: attr('number'),
  'entity-count': attr('number'),
  entities_mentioned: hasMany('entity'),
  entities_mentioned_list: attr('string'),
  formatted_date: attr('string'),

  dateSent: computed('date', function() {
    const date = new Date(this.get('date'));
    return `${date.getUTCDate()} ${date.toLocaleString('en-us', { month: 'long' })} ${date.getFullYear()}`;
  })
});
