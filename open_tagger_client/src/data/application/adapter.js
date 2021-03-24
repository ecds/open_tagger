import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  init() {
    this._super(...arguments);
    this.set('headers', {
      'X-API-KEY': 'secret butt'
    });
    console.log(this)
  },

  deleteRecord(store, type, snapshot) {
    this._super(...arguments);
    console.log("deleteRecord -> store, type, snapshot", store, type, snapshot)
    var id = snapshot.id;
    return this.ajax(this.buildURL(type.modelName, id, snapshot, 'deleteRecord'), 'DELETE', {});
  }
});