import EmberRouter from "@ember/routing/router";
import config from "../config/environment";

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('people');
  this.route('letters');
  this.route('letter', {
    path: '/letters/:letter_id'
  });
  this.route('entities', {
    path: '/entities/:entity_type'
  }, function() {
    this.route('entity');
  });
});

export default Router;
