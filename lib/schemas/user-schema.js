(function() {
  var EmailSchema, UserIdentitySchema, UserImageSchema, UserProfileSchema, UserSchema, _, mongoose, pluginDeleteParanoid, pluginResourceLimits, pluginTimestamp;

  mongoose = require('mongoose');

  _ = require('underscore');

  pluginTimestamp = require("mongoose-plugins-timestamp");

  pluginDeleteParanoid = require("mongoose-plugins-delete-paranoid");

  pluginResourceLimits = require("mongoose-plugins-resource-limits");

  EmailSchema = require('./email-schema');

  UserIdentitySchema = require('./user-identity-schema');

  UserProfileSchema = require('./user-profile-schema');

  UserImageSchema = require('./user-image-schema');

  module.exports = UserSchema = new mongoose.Schema({
    _tenantId: {
      type: mongoose.Schema.ObjectId,
      require: true,
      index: true
    },
    username: {
      type: String
    },
    displayName: {
      type: String
    },
    password: {
      type: String
    },
    identities: {
      type: [UserIdentitySchema],
      "default": []
    },
    profileLinks: {
      type: [UserProfileSchema],
      "default": []
    },
    userImages: {
      type: [UserImageSchema],
      "default": []
    },
    selectedUserImage: {
      type: String
    },
    primaryEmail: {
      type: String
    },
    emails: {
      type: [exports.EmailSchema],
      "default": []
    },
    roles: {
      type: [String],
      "default": []
    },
    onboardingState: {
      type: String,
      "default": null
    },
    needsInit: {
      type: Boolean,
      "default": false
    },
    data: {
      type: mongoose.Schema.Types.Mixed,
      "default": function() {
        return {};
      }
    },
    stats: {
      type: mongoose.Schema.Types.Mixed,
      "default": function() {
        return {};
      }
    },
    description: {
      type: String,
      trim: true,
      "default": '',
      match: /.{0,500}/
    },
    gender: {
      type: String,
      "default": ''
    },
    timezone: {
      type: Number,
      "default": 0
    },
    locale: {
      type: String,
      "default": 'en_us'
    },
    verified: {
      type: Boolean,
      "default": false
    },
    title: {
      type: String
    },
    location: {
      type: String
    },
    resetPasswordToken: {
      type: {
        token: String,
        validTill: Date
      }
    }
  }, {
    strict: true,
    collection: 'identitymt.users'
  });

  UserSchema.index({
    _tenantId: 1,
    username: 1
  }, {
    unique: true,
    sparse: false
  });

  UserSchema.index({
    _tenantId: 1,
    primaryEmail: 1
  }, {
    unique: true,
    sparse: true
  });

  UserSchema.plugin(pluginTimestamp.timestamps);

  UserSchema.plugin(pluginDeleteParanoid.deleteParanoid);

  UserSchema.plugin(pluginResourceLimits.resourceLimits);

  UserSchema.pre('save', function(next) {
    if (this.username) {
      this.username = this.username.toLowerCase();
    }
    if (this.primaryEmail) {
      this.primaryEmail = this.primaryEmail.toLowerCase();
    }
    return next();
  });

  UserSchema.methods.toActor = function() {
    var actor;
    actor = {
      actorId: this._id
    };
    return actor;
  };

}).call(this);

//# sourceMappingURL=user-schema.js.map
