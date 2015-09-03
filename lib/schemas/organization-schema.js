(function() {
  var Boom, Hoek, OrganizationLinkType, OrganizationSchema, OrganizationStatsType, _, fnUnprocessableEntity, i18n, mongoose, mongooseRestHelper, pluginAccessibleBy, pluginCreatedBy, pluginDeleteParanoid, pluginResourceLimits, pluginTagsSimple, pluginTimestamp;

  _ = require('underscore');

  mongoose = require('mongoose');

  Hoek = require('hoek');

  Boom = require('boom');

  i18n = require('../i18n');

  mongooseRestHelper = require('mongoose-rest-helper');

  fnUnprocessableEntity = function(message, data) {
    if (message == null) {
      message = "";
    }
    return Boom.create(422, message, data);
  };

  pluginAccessibleBy = require("mongoose-plugins-accessible-by");

  pluginTimestamp = require("mongoose-plugins-timestamp");

  pluginCreatedBy = require("mongoose-plugins-created-by");

  pluginTagsSimple = require("mongoose-plugins-tags-simple");

  pluginDeleteParanoid = require("mongoose-plugins-delete-paranoid");

  pluginResourceLimits = require("mongoose-plugins-resource-limits");

  OrganizationStatsType = {
    accessCount: {
      type: Number,
      "default": 0
    }
  };

  OrganizationLinkType = {
    target: {
      type: String
    },
    mimeType: {
      type: String
    }
  };

  module.exports = OrganizationSchema = new mongoose.Schema({
    _tenantId: {
      type: mongoose.Schema.ObjectId,
      require: true,
      index: true
    },
    name: {
      type: String,
      trim: true,
      required: true,
      match: /.{2,40}/
    },
    description: {
      type: String,
      trim: true,
      "default": '',
      match: /.{0,500}/
    },
    stats: {
      type: OrganizationStatsType,
      "default": function() {
        return {
          numberOfClones: 0
        };
      }
    },
    profileLinks: {
      type: [OrganizationLinkType],
      "default": function() {
        return [];
      }
    },
    data: {
      type: mongoose.Schema.Types.Mixed,
      "default": function() {
        return {};
      }
    }
  }, {
    strict: true,
    collection: 'identitymt.organizations'
  });

  OrganizationSchema.index({
    _tenantId: 1,
    name: 1
  }, {
    unique: true,
    sparse: false
  });

  OrganizationSchema.plugin(pluginTimestamp.timestamps);

  OrganizationSchema.plugin(pluginCreatedBy.createdBy, {
    isRequired: false,
    v: 2,
    keepV1: false
  });

  OrganizationSchema.plugin(pluginTagsSimple.tagsSimple);

  OrganizationSchema.plugin(pluginDeleteParanoid.deleteParanoid);

  OrganizationSchema.plugin(pluginAccessibleBy.accessibleBy, {
    defaultIsPublic: true
  });

  OrganizationSchema.plugin(pluginResourceLimits.resourceLimits);


  /*
  @TODO CHeck if needed at all
   */

  OrganizationSchema.statics.findOneValidate = function(organizationId, actor, role, cb) {
    var Organization;
    if (cb == null) {
      cb = function() {};
    }
    if (!organizationId) {
      return cb(fnUnprocessableEntity(i18n.errorOrganizationIdRequired));
    }

    /*
    @TODO BUG FIX - TEST
     */
    organizationId = mongooseRestHelper.asObjectId(organizationId);
    Organization = this;
    return Organization.findOne({
      _id: organizationId
    }, (function(_this) {
      return function(err, item) {
        if (err) {
          return cb(err);
        }
        if (!item) {
          return cb(Boom.notFound(i18n.prefixErrorCouldNotFindOrganization + " " + organizationId));
        }
        if (item.canPublicAccess(role)) {
          return cb(null, item);
        }
        if (actor && item.canActorAccess(actor, role)) {
          return cb(null, item);
        }
        if (actor && item.createdBy.actorId.toString() === actor.actorId.toString()) {
          return cb(null, item);
        }
        return cb(Boom.forbidden(i18n.prefixErrorForbiddenForOrganization + " " + organizationId));
      };
    })(this));
  };

  OrganizationSchema.statics.findOneValidateRead = function(organizationId, actor, cb) {
    if (cb == null) {
      cb = function() {};
    }
    return this.findOneValidate(organizationId, actor, "read", cb);
  };

  OrganizationSchema.statics.findOneValidateWrite = function(organizationId, actor, cb) {
    if (cb == null) {
      cb = function() {};
    }
    return this.findOneValidate(organizationId, actor, "write", cb);
  };

}).call(this);

//# sourceMappingURL=organization-schema.js.map
