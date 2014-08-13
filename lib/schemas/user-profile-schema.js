(function() {
  var UserProfileSchema, mongoose;

  mongoose = require('mongoose');

  module.exports = UserProfileSchema = new mongoose.Schema({
    linkUrl: {
      type: String
    },
    linkIdentifier: {
      type: String
    },
    provider: {
      type: String
    },
    linkType: {
      type: String
    },
    linkSubType: {
      type: String
    },
    caption: {
      type: String
    },
    isPublic: {
      type: Boolean,
      "default": false
    }
  });

}).call(this);

//# sourceMappingURL=user-profile-schema.js.map
