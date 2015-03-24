(function() {
  var AdminMethods, EmailSchema, EntityMethods, OrganizationMethods, OrganizationSchema, RoleMethods, RoleSchema, Store, UserIdentitySchema, UserImageSchema, UserMethods, UserProfileSchema, UserProviderMethods, UserSchema, mongoose, _;

  _ = require('underscore');

  mongoose = require('mongoose');

  EmailSchema = require('./schemas/email-schema');

  OrganizationSchema = require('./schemas/organization-schema');

  RoleSchema = require('./schemas/role-schema');

  UserIdentitySchema = require('./schemas/user-identity-schema');

  UserImageSchema = require('./schemas/user-image-schema');

  UserProfileSchema = require('./schemas/user-profile-schema');

  UserSchema = require('./schemas/user-schema');

  AdminMethods = require('./methods/admin-methods');

  EntityMethods = require('./methods/entity-methods');

  OrganizationMethods = require('./methods/organization-methods');

  RoleMethods = require('./methods/role-methods');

  UserMethods = require('./methods/user-methods');

  UserProviderMethods = require('./methods/user-provider-methods');

  module.exports = Store = (function() {

    /*
    Initializes a new instance of the {Store}
    @param [Object] settings configuration options for this store
    @option settings [Function] initializeSchema optional function that is called with the schema before it is converted to a model.
    @option settings [Boolean] autoIndex defaults to true and updates the db indexes on load. Should be off for production.
     */
    function Store(settings) {
      var m, schema, _i, _j, _len, _len1, _ref, _ref1;
      this.settings = settings != null ? settings : {};
      _.defaults(this.settings, {
        autoIndex: true,
        initializeSchema: function(schema) {}
      });
      this.schemas = [EmailSchema, OrganizationSchema, RoleSchema, UserIdentitySchema, UserImageSchema, UserProfileSchema, UserSchema];
      _ref = this.schemas;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        schema = _ref[_i];
        this.settings.initializeSchema(schema);
      }
      _ref1 = this.schemas;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        schema = _ref1[_j];
        schema.set('autoIndex', this.settings.autoIndex);
      }
      m = mongoose;
      if (this.settings.connection) {
        m = this.settings.connection;
      }
      this.models = {
        Organization: m.model("Organization", OrganizationSchema),
        Role: m.model("Role", RoleSchema),
        User: m.model("User", UserSchema)
      };
      this.entities = new EntityMethods(this.models);
      this.organizations = new OrganizationMethods(this.models);
      this.roles = new RoleMethods(this.models);
      this.users = new UserMethods(this.models);
      this.userProviders = new UserProviderMethods(this.models);
      this.admin = new AdminMethods(this.models, this.users, this.oauthApps, this.oauthAuth, this.oauthScopes);
    }

    return Store;

  })();

}).call(this);

//# sourceMappingURL=store.js.map
