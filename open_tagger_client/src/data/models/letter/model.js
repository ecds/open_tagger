import DS from 'ember-data';
import { computed } from '@ember/object';

const {
  Model,
  attr,
  belongsTo,
  hasMany
} = DS;

export default Model.extend({
  letter_code: attr('string'),
  content: attr('string'),
  recipients: hasMany('people'),
  'date_sent': attr('date'),
  month: attr('number'),
  year: attr('number'),
  'sent_from_actual': belongsTo('literal'),
  'sent_to_actual': belongsTo('literal'),
  repositories: hasMany('repository'),
  collections: hasMany('collection'),
  language: belongsTo('language'),
  public: attr('boolean'),
  leaves: attr('number'),
  postmark: attr('string'),
  verified: attr('boolean'),
  envelope: attr('string'),
  sides: attr('number'),
  'recipient_list': attr('string'),
  'legacy_pk': attr('number'),
  entities: hasMany('entity'),

  dateSent: computed('date_sent', function() {
    const date = new Date(this.get('date_sent'));
    return `${date.getDate()} ${date.toLocaleString('en-us', { month: 'long' })} ${date.getFullYear()}`;
  })
});
