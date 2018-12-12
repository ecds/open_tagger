import DS from 'ember-data';

// export default DS.RESTAdapter.extend({
//   host: 'http://localhost:3000',
//     urlForQuery (query, modelName) {
//       console.log(query, modelName)
//       switch(modelName) {
//         case 'quad':
//           return `${this.host}/${modelName}s/${query}`;
//         default:
//           return this._super(...arguments);
//       }
//     }
// });

export default DS.JSONAPIAdapter.extend({
  host: 'http://192.168.26.128:3000',
});