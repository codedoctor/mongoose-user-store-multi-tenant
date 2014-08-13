_ = require 'underscore'
mongoose = require 'mongoose'


EmailSchema = require './schemas/email-schema'
OrganizationSchema = require './schemas/organization-schema'
RoleSchema = require './schemas/role-schema'
UserIdentitySchema = require './schemas/user-identity-schema'
UserImageSchema = require './schemas/user-image-schema'
UserProfileSchema = require './schemas/user-profile-schema'
UserSchema = require './schemas/user-schema'

AdminMethods = require './methods/admin-methods'
EntityMethods = require './methods/entity-methods'
OrganizationMethods = require './methods/organization-methods'
RoleMethods = require './methods/role-methods'
UserMethods = require './methods/user-methods'

module.exports = class Store

  ###
  Initializes a new instance of the {Store}
  @param [Object] settings configuration options for this store
  @option settings [Function] initializeSchema optional function that is called with the schema before it is converted to a model.
  @option settings [Boolean] autoIndex defaults to true and updates the db indexes on load. Should be off for production.
  ###
  constructor: (@settings = {}) ->
    _.defaults @settings, 
                  autoIndex : true
                  initializeSchema: (schema) -> 

    @schemas = [
      EmailSchema
      OrganizationSchema
      RoleSchema
      UserIdentitySchema
      UserImageSchema
      UserProfileSchema
      UserSchema
    ]

    @settings.initializeSchema schema for schema in @schemas
    schema.set 'autoIndex', @settings.autoIndex for schema in @schemas

    m = mongoose
    m = @settings.connection if @settings.connection

    @models =
      Organization : m.model "Organization", OrganizationSchema
      Role : m.model "Role", RoleSchema
      User : m.model "User", UserSchema
    
    @entities = new EntityMethods @models
    @organizations = new OrganizationMethods @models
    @roles = new RoleMethods @models
    @users = new UserMethods @models
    @admin = new AdminMethods @models, @users, @oauthApps, @oauthAuth,@oauthScopes

