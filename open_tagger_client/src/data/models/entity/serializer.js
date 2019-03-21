import DS from 'ember-data';

export default DS.JSONAPISerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    entityType: { embedded: 'always' }
  }
});
