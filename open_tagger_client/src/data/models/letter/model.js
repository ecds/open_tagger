import DS from 'ember-data';
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
  'date_sent': attr(),
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
  sides: attr('number')
});
