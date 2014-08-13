(function() {
  var EmailSchema, mongoose;

  mongoose = require('mongoose');

  module.exports = EmailSchema = new mongoose.Schema({
    email: {
      type: String,
      unique: true,
      sparse: true
    },
    isVerified: {
      type: Boolean
    },
    sendNotifications: {
      type: Boolean
    }
  });

}).call(this);

//# sourceMappingURL=email-schema.js.map
