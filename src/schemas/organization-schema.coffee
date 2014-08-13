_ = require 'underscore'
mongoose = require 'mongoose'
Hoek = require 'hoek'
Boom = require 'boom'
i18n = require '../i18n'
mongooseRestHelper = require 'mongoose-rest-helper'

fnUnprocessableEntity = (message = "",data) ->
  return Boom.create 422, message, data

pluginAccessibleBy = require "mongoose-plugins-accessible-by"
pluginTimestamp = require "mongoose-plugins-timestamp"
pluginCreatedBy = require "mongoose-plugins-created-by"
pluginTagsSimple = require "mongoose-plugins-tags-simple"
pluginDeleteParanoid = require "mongoose-plugins-delete-paranoid"
pluginResourceLimits = require "mongoose-plugins-resource-limits"

OrganizationStatsType =
  accessCount:
    type : Number
    default : 0

OrganizationLinkType =
  target :
    type : String
  mimeType :
    type : String

module.exports = OrganizationSchema = new mongoose.Schema
    _tenantId:
      type: mongoose.Schema.ObjectId
      require: true
      index: true
    name:
      type : String
      trim : true
      required: true
      match: /.{2,40}/
    description :
      type : String
      trim: true
      default: ''
      match: /.{0,500}/
    stats:
      type: OrganizationStatsType
      default : () ->
        numberOfClones : 0
    profileLinks: # Links from external sources that link to this
      type: [OrganizationLinkType]
      default : () -> []
    data:
      type: mongoose.Schema.Types.Mixed
      default : () -> {}
  ,
    strict: true
    collection: 'identitymt.organizations'

OrganizationSchema.index({ _tenantId: 1,name: 1 },{ unique: true, sparse: false} );


OrganizationSchema.plugin pluginTimestamp.timestamps
OrganizationSchema.plugin pluginCreatedBy.createdBy,{isRequired : false, v:2, keepV1 : false}
OrganizationSchema.plugin pluginTagsSimple.tagsSimple
OrganizationSchema.plugin pluginDeleteParanoid.deleteParanoid
OrganizationSchema.plugin pluginAccessibleBy.accessibleBy, defaultIsPublic : true
OrganizationSchema.plugin pluginResourceLimits.resourceLimits

###
@TODO CHeck if needed at all
###

OrganizationSchema.statics.findOneValidate = (organizationId, actor, role, cb = ->) ->
  return cb fnUnprocessableEntity( i18n.errorOrganizationIdRequired) unless organizationId

  ###
  @TODO BUG FIX - TEST
  ###
  organizationId = mongooseRestHelper.asObjectId organizationId
  Organization = @

  Organization.findOne _id : organizationId, (err, item) =>
    return cb err if err

    return cb Boom.notFound("#{i18n.prefixErrorCouldNotFindOrganization} #{organizationId}") unless item

    return cb null, item if item.canPublicAccess(role)
    return cb null, item if actor && item.canActorAccess(actor, role)
    return cb null, item if actor && item.createdBy.actorId.toString() is actor.actorId.toString()

    cb Boom.forbidden("#{i18n.prefixErrorForbiddenForOrganization} #{organizationId}") 


OrganizationSchema.statics.findOneValidateRead = (organizationId, actor, cb = ->) ->
  @findOneValidate organizationId, actor, "read", cb


OrganizationSchema.statics.findOneValidateWrite = (organizationId, actor, cb = ->) ->
  @findOneValidate organizationId, actor, "write", cb
