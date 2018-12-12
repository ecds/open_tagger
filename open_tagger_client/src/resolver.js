import Resolver from 'ember-resolver/resolvers/fallback';
import buildResolverConfig from 'ember-resolver/ember-config';
import config from '../config/environment';
import { merge } from '@ember/polyfills';

let moduleConfig = buildResolverConfig(config.modulePrefix);
/*
 * If your application has custom types and collections, modify moduleConfig here
 * to add support for them.
 */

// for ember-gesture that is required by ember-uikit
merge(moduleConfig.types, {
  'ember-gesture': { definitiveCollection: 'main' }
});

export default Resolver.extend({
  config: moduleConfig
});
