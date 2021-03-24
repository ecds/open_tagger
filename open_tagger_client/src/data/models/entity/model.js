import DS from 'ember-data';
import { computed } from '@ember/object';
import { htmlSafe } from '@ember/string';

const { Model, attr, hasMany, belongsTo } = DS;

export default Model.extend({
  label: attr('string'),
  description: attr('string'),
  literals: hasMany('literal'),
  entityType: belongsTo('entity-type'),
  suggestion: attr('string'),
  letters: hasMany('letter'),
  properties: attr(),
  type_label: attr('string'),
  flagged: attr('boolean'),
  deletable: attr('boolean'),

  safeLabel: computed('label', function() {
    return new htmlSafe(this.get('label'));
  }),

  altSpellings: computed('properties', function() {
    if (!this.get('properties')) {
      return null;
    }
    let alt = this.get('properties')['alternate-names-spellings']
    if (alt && alt.length > 0) {
      return alt.join(',');
    } else {
      return null;
    }
  })
});
