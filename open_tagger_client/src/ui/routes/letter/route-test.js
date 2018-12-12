import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | letters/letter', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:letters/letter');
    assert.ok(route);
  });
});
