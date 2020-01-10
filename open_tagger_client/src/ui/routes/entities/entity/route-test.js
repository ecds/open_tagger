import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | entities/entity', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:entities/entity');
    assert.ok(route);
  });
});
