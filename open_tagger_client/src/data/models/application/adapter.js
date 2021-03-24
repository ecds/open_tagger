import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  init() {
    this._super(...arguments);
    this.set('headers', {
      'X-API-KEY': 'secret'
    });
  },

  host: 'https://ot-api.ecdsdev.org',

  deleteRecord(store, type, snapshot) {
    console.log("deleteRecord -> store, type, snapshot", store, type, snapshot)
    var id = snapshot.id;
    return this.ajax(this.buildURL(type.modelName, id, snapshot, 'deleteRecord'), 'DELETE', {});
  }
  // host: 'http://192.168.56.200:3000'
});
