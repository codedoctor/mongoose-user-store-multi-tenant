
/*
Storage functionality for modeista-identity
 */

(function() {
  var Store;

  Store = require('./store');

  module.exports = {
    Store: Store,
    store: function(settings) {
      if (settings == null) {
        settings = {};
      }
      return new Store(settings);
    }
  };

}).call(this);

//# sourceMappingURL=index.js.map
