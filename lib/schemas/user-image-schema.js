(function() {
  var UserImageSchema, mongoose;

  mongoose = require('mongoose');

  module.exports = UserImageSchema = new mongoose.Schema({
    url: {
      type: String
    }
  });

}).call(this);

//# sourceMappingURL=user-image-schema.js.map
