(function() {
  var UserIdentitySchema, mongoose, _;

  mongoose = require('mongoose');

  _ = require('underscore');

  module.exports = UserIdentitySchema = new mongoose.Schema({
    provider: {
      type: String
    },
    key: {
      type: String
    },
    v1: {
      type: String
    },
    v2: {
      type: String
    },
    providerType: {
      type: String,
      "default": "oauth"
    },
    profileImage: {
      type: String,
      "default": ''
    },
    username: {
      type: String,
      "default": ''
    },
    displayName: {
      type: String,
      "default": ''
    }
  });

}).call(this);

//# sourceMappingURL=user-identity-schema.js.map
