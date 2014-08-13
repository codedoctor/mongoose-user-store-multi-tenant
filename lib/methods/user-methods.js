(function() {
  var Boom, Hoek, PageResult, UserMethods, bcrypt, fnUnprocessableEntity, i18n, isObjectId, mongooseRestHelper, passgen, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('underscore-ext');

  bcrypt = require('bcryptjs');

  Boom = require('boom');

  Hoek = require('hoek');

  mongooseRestHelper = require('mongoose-rest-helper');

  passgen = require('passgen');

  isObjectId = require('mongodb-objectid-helper').isObjectId;

  i18n = require('../i18n');

  PageResult = require('../page-result');

  require('date-utils');

  fnUnprocessableEntity = function(message, data) {
    if (message == null) {
      message = "";
    }
    return Boom.create(422, message, data);
  };


  /*
  Provides methods to interact with scotties.
   */

  module.exports = UserMethods = (function() {

    /*
    @TODO INVERT THIS LIKE EVERYWHERE ELSE
     */
    var UPDATE_FIELDS_FULL, resetPasswordTokenLength;

    UPDATE_FIELDS_FULL = ['username', 'description', 'displayName', 'identities', 'primaryEmail', 'profileLinks', 'userImages', 'selectedUserImage', 'emails', 'roles', 'data', 'resourceLimits', 'onboardingState', 'title', 'location', 'needsInit'];


    /*
    Initializes a new instance of the {UserMethods} class.
    @param {Object} models A collection of models that can be used.
     */

    function UserMethods(models) {
      this.models = models;
      this.removeEmail = __bind(this.removeEmail, this);
      this.addEmail = __bind(this.addEmail, this);
      this.resetPasswordToken = __bind(this.resetPasswordToken, this);
      this.resetPassword = __bind(this.resetPassword, this);
      this.removeRoles = __bind(this.removeRoles, this);
      this.addRoles = __bind(this.addRoles, this);
      this.removeIdentityFromUser = __bind(this.removeIdentityFromUser, this);
      this.addIdentityToUser = __bind(this.addIdentityToUser, this);
      this._profileImageFromProfile = __bind(this._profileImageFromProfile, this);
      this._displayNameFromProfile = __bind(this._displayNameFromProfile, this);
      this._usernameFromProfile = __bind(this._usernameFromProfile, this);
      this.getOrCreateUserFromProvider = __bind(this.getOrCreateUserFromProvider, this);
      this.create = __bind(this.create, this);
      this._hashPassword = __bind(this._hashPassword, this);
      this.validateUserByUsernameOrEmail = __bind(this.validateUserByUsernameOrEmail, this);
      this.findUserByUsernameOrEmail = __bind(this.findUserByUsernameOrEmail, this);
      this.setPassword = __bind(this.setPassword, this);
      this.destroy = __bind(this.destroy, this);
      this["delete"] = __bind(this["delete"], this);
      this.patch = __bind(this.patch, this);
      this.getByNameOrId = __bind(this.getByNameOrId, this);
      this.getByPrimaryEmail = __bind(this.getByPrimaryEmail, this);
      this.getByName = __bind(this.getByName, this);
      this.lookup = __bind(this.lookup, this);
      this.getByUsernames = __bind(this.getByUsernames, this);
      this.getByIds = __bind(this.getByIds, this);
      this.get = __bind(this.get, this);
      this.all = __bind(this.all, this);
      Hoek.assert(this.models, i18n.assertModelsRequired);
      Hoek.assert(this.models.User, i18n.assertUserInModelsRequired);
    }


    /*
    Retrieve all users for a specific _tenantId
     */

    UserMethods.prototype.all = function(_tenantId, options, cb) {
      var settings;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      settings = {
        baseQuery: {
          _tenantId: mongooseRestHelper.asObjectId(_tenantId)
        },
        defaultSort: 'username',
        defaultSelect: null,
        defaultCount: 50
      };
      return mongooseRestHelper.all(this.models.User, settings, options, cb);
    };


    /*
    Retrieves a user by it's id.
     */

    UserMethods.prototype.get = function(userId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!userId) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      return mongooseRestHelper.getById(this.models.User, userId, null, options, cb);
    };


    /*
    Retrieves users by passing a list of id's, which can be string or objectIds
     */

    UserMethods.prototype.getByIds = function(idList, options, cb) {
      if (idList == null) {
        idList = [];
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      idList = _.map(idList, function(x) {
        return mongooseRestHelper.asObjectId(x);
      });
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      return this.models.User.find({}).where('_id')["in"](idList).exec((function(_this) {
        return function(err, users) {
          if (err) {
            return cb(err);
          }
          users || (users = []);
          return cb(null, new PageResult(users, users.length, 0, users.length));
        };
      })(this));
    };


    /*
    Retrieves users by passing a list of usernames.
    @param {[String]} usernames an array of usernames. Case insensitive
    @param {Object} options a set of options, which can be null
    @param {Function} cb a callback that is invoked after completion of this method.
    @option options [String] select the space separated fields to return, which default to all.
     */

    UserMethods.prototype.getByUsernames = function(_tenantId, usernames, options, cb) {
      var query;
      if (usernames == null) {
        usernames = [];
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      usernames = _.map(usernames, function(x) {
        return x.toLowerCase();
      });
      query = this.models.User.find({
        _tenantId: _tenantId
      }).where('username')["in"](usernames);
      if (options.select && options.select.length > 0) {
        query = query.select(options.select);
      }
      return query.exec((function(_this) {
        return function(err, users) {
          if (err) {
            return cb(err);
          }
          users || (users = []);
          return cb(null, new PageResult(users, users.length, 0, usernames.length));
        };
      })(this));
    };


    /*
    Returns a list of users who match q. In this version we do a straight user name match.
    @param {String} q a search string.
    @param {Object} options a set of options, which can be null
    @param {Function} cb a callback that is invoked after completion of this method.
    @option options [Integer] limit the maximum number of results to return, defaults to 10.
    @option options [String] sortOrder the sort order in mongodb syntax, which defaults to 'username'.
    @option options [String] select the space separated fields to return, which default to '_id username displayName selectedUserImage'.
     */

    UserMethods.prototype.lookup = function(_tenantId, q, options, cb) {
      var r;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      q = (q || '').toLowerCase().trim();
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      options.limit || (options.limit = 10);
      options.sortOrder || (options.sortOrder = 'username');
      options.select || (options.select = '_id username displayName selectedUserImage');
      r = new RegExp("^" + q);
      return this.models.User.find({
        _tenantId: _tenantId,
        username: r
      }).select(options.select).sort(options.sortOrder).limit(options.limit).exec((function(_this) {
        return function(err, users) {
          if (err) {
            return cb(err);
          }
          users || (users = []);
          return cb(null, new PageResult(users, users.length, 0, users.length));
        };
      })(this));
    };

    UserMethods.prototype.getByName = function(_tenantId, name, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (!name) {
        return cb(fnUnprocessableEntity(i18n.errorNameRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      name = name.toLowerCase();
      return this.models.User.findOne({
        _tenantId: _tenantId,
        username: name
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          return cb(null, user);
        };
      })(this));
    };

    UserMethods.prototype.getByPrimaryEmail = function(_tenantId, email, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorEmailRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      email = email.toLowerCase();
      return this.models.User.findOne({
        _tenantId: _tenantId,
        primaryEmail: email
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          return cb(null, user);
        };
      })(this));
    };

    UserMethods.prototype.getByNameOrId = function(_tenantId, nameOrId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (isObjectId(nameOrId)) {
        return this.get(nameOrId, cb);
      } else {
        return this.getByName(_tenantId, nameOrId, cb);
      }
    };

    UserMethods.prototype.patch = function(_tenantId, usernameOrId, obj, options, cb) {
      if (obj == null) {
        obj = {};
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      return this.getByNameOrId(_tenantId, usernameOrId, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + usernameOrId));
          }
          _.extendFiltered(user, UPDATE_FIELDS_FULL, obj);
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            if (obj.password) {
              return _this.setPassword(_tenantId, usernameOrId, obj.password, {}, function(err, user2) {
                if (err) {
                  return cb(err);
                }
                return cb(null, user);
              });
            } else {
              return cb(null, user);
            }
          });
        };
      })(this));
    };

    UserMethods.prototype["delete"] = function(_tenantId, usernameOrId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      return this.getByNameOrId(_tenantId, usernameOrId, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + usernameOrId));
          }
          if (user.isDeleted) {
            return cb(null);
          }
          user.isDeleted = true;
          user.deletedAt = new Date();
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user);
          });
        };
      })(this));
    };

    UserMethods.prototype.destroy = function(_tenantId, usernameOrId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      return this.getByNameOrId(_tenantId, usernameOrId, {}, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + usernameOrId));
          }
          return user.remove(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user);
          });
        };
      })(this));
    };

    UserMethods.prototype.setPassword = function(_tenantId, usernameOrId, password, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      return this.getByNameOrId(_tenantId, usernameOrId, {}, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!(user && !user.isDeleted)) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + usernameOrId));
          }
          return _this._hashPassword(password, function(err, hash) {
            if (err) {
              return cb(err);
            }
            user.password = hash;
            return user.save(function(err) {
              if (err) {
                return cb(err);
              }
              return cb(null, user);
            });
          });
        };
      })(this));
    };


    /*
    Looks up a user by username or email.
     */

    UserMethods.prototype.findUserByUsernameOrEmail = function(_tenantId, usernameOrEmail, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      usernameOrEmail = usernameOrEmail.toLowerCase();
      return this.models.User.findOne({
        _tenantId: _tenantId,
        username: usernameOrEmail
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (user) {
            return cb(null, user);
          }
          return _this.models.User.findOne({
            _tenantId: _tenantId,
            primaryEmail: usernameOrEmail
          }, function(err, user) {
            if (err) {
              return cb(err);
            }
            return cb(null, user);
          });
        };
      })(this));
    };


    /*
    Looks up the user, if found validates against password.
    cb(err) in case of non password error.
    cb(null, user) in case of user not found, password not valid, or valid user
     */

    UserMethods.prototype.validateUserByUsernameOrEmail = function(_tenantId, usernameOrEmail, password, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      usernameOrEmail = usernameOrEmail.toLowerCase();
      return this.findUserByUsernameOrEmail(_tenantId, usernameOrEmail, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(null, null);
          }
          return bcrypt.compare(password, user.password, function(err, res) {
            if (err) {
              return cb(err);
            }
            if (!res) {
              return cb(null, null);
            }
            return cb(null, user);
          });
        };
      })(this));
    };

    UserMethods.prototype._hashPassword = function(password, cb) {
      return bcrypt.genSalt(10, (function(_this) {
        return function(err, salt) {
          if (err) {
            return cb(err);
          }
          return bcrypt.hash(password, salt, function(err, hash) {
            if (err) {
              return cb(err);
            }
            return cb(null, hash);
          });
        };
      })(this));
    };


    /*
    Creates a new user.
     */

    UserMethods.prototype.create = function(_tenantId, objs, options, cb) {
      var user;
      if (objs == null) {
        objs = {};
      }
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      _.defaults(objs, {
        username: null,
        primaryEmail: null,
        password: null
      });
      if (objs.email && !objs.primaryEmail) {
        objs.primaryEmail = objs.email;
      }
      delete objs.email;
      objs._tenantId = _tenantId;
      user = new this.models.User(objs);
      if (objs.primaryEmail) {
        user.emails = [objs.primaryEmail];
      }

      /*
      var gravatar = require('gravatar');
      var url = gravatar.url('emerleite@gmail.com', {s: '200', r: 'pg', d: '404'});
       */
      return this._hashPassword(objs.password, (function(_this) {
        return function(err, hash) {
          if (err) {
            return cb(err);
          }
          user.password = hash;
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user);
          });
        };
      })(this));
    };


    /*
    Gets or creates a user for a given provider/profile combination.
    @param {String} provider a provider string like "facebook" or "twitter".
    @param {String} v1 the key or access_token, depending on the type of provider
    @param {String} v2 the secret or refresh_token, depending on the type of provider
    @param {Object} profile The profile as defined here: http://passportjs.org/guide/user-profile.html
     */

    UserMethods.prototype.getOrCreateUserFromProvider = function(_tenantId, provider, v1, v2, profile, options, cb) {
      var identityQuery, isNew;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!(profile && profile.id)) {
        return cb(fnUnprocessableEntity(i18n.errorIdWithinProfileRequired));
      }
      _tenantId = mongooseRestHelper.asObjectId(_tenantId);
      identityQuery = {
        _tenantId: _tenantId,
        'identities.provider': provider,
        'identities.key': profile.id
      };
      isNew = false;
      return this.models.User.findOne(identityQuery, (function(_this) {
        return function(err, user) {
          var identity, isUserNameValid, pusername, _i, _len, _ref;
          if (err) {
            return cb(err);
          }
          if (user) {
            _ref = user.identities;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              identity = _ref[_i];
              if (identity.provider === provider) {
                identity.v1 = v1;
                identity.v2 = v2;
              }
            }
            return user.save(function(err) {
              if (err) {
                return cb(err);
              }
              return cb(null, user, {
                isNew: isNew
              });
            });
          } else {
            isNew = true;
            isUserNameValid = true;
            pusername = profile.username || ("fb" + profile.id);
            return _this.models.User.findOne({
              _tenantId: _tenantId,
              username: pusername
            }, function(err, userXX) {
              var email, emails, imageUrl, images, newIdentity, _j, _k, _len1, _len2, _ref1, _ref2, _ref3, _ref4, _ref5;
              if (err) {
                return cb(err);
              }
              isUserNameValid = !userXX;

              /*
              { "_json" : { "email" : "martin@wawrusch.com",
                    "favorite_athletes" : [ { "id" : "69025400418",
                "name" : "Kobe Bryant"
              },
              { "id" : "34778334225",
                "name" : "Kelly Slater"
              }
                      ],
                    "favorite_teams" : [ { "id" : "144917055340",
                "name" : "LA Lakers"
              } ],
                    "first_name" : "Martin",
                    "gender" : "male",
                    "id" : "679841881",
                    "last_name" : "Wawrusch",
                    "link" : "http://www.facebook.com/martinw",
                    "locale" : "en_US",
                    "location" : { "id" : "109434625742337",
              "name" : "West Hollywood, California"
                      },
                    "name" : "Martin Wawrusch",
                    "timezone" : -8,
                    "updated_time" : "2012-10-31T18:05:42+0000",
                    "username" : "martinw",
                    "verified" : true
                  },
                "_raw" : "{\"id\":\"679841881\",\"name\":\"Martin Wawrusch\",\"first_name\":\"Martin\",\"last_name\":\"Wawrusch\",\"link\":\"http:\\/\\/www.facebook.com\\/martinw\",\"username\":\"martinw\",\"location\":{\"id\":\"109434625742337\",\"name\":\"West Hollywood, California\"},\"favorite_teams\":[{\"id\":\"144917055340\",\"name\":\"LA Lakers\"}],\"favorite_athletes\":[{\"id\":\"69025400418\",\"name\":\"Kobe Bryant\"},{\"id\":\"34778334225\",\"name\":\"Kelly Slater\"}],\"gender\":\"male\",\"email\":\"martin\\u0040wawrusch.com\",\"timezone\":-8,\"locale\":\"en_US\",\"verified\":true,\"updated_time\":\"2012-10-31T18:05:42+0000\"}",
                "displayName" : "Martin Wawrusch",
                "emails" : [ { "value" : "martin@wawrusch.com" } ],
                "gender" : "male",
                "id" : "679841881",
                "name" : { "familyName" : "Wawrusch",
                    "givenName" : "Martin"
                  },
                "profileUrl" : "http://www.facebook.com/martinw",
                "provider" : "facebook",
                "username" : "martinw"
              }
               */
              user = new _this.models.User;
              user._tenantId = _tenantId;
              user.username = (isUserNameValid ? pusername : pusername + passgen.create(4)).toLowerCase();
              user.displayName = profile.displayName || user.username || pusername;
              user.data = {};
              user.description = profile.description || '';
              user.title = "";
              images = [];
              if (provider === 'twitter' && profile.photos && _.isArray(profile.photos)) {
                images = profile.photos;
              }
              if (profile.username && provider === "facebook") {
                images.push("https://graph.facebook.com/" + (profile.username || profile.id) + "/picture");
              }
              for (_j = 0, _len1 = images.length; _j < _len1; _j++) {
                imageUrl = images[_j];
                user.userImages.push({
                  url: imageUrl
                });
              }
              if (profile.profile_image_url && profile.profile_image_url.length > 5) {
                user.selectedUserImage = profile.profile_image_url;
              } else {
                if (images.length > 0) {
                  user.selectedUserImage = images[0];
                }
              }
              if (provider === "facebook" && profile.profileUrl) {
                user.profileLinks.push({
                  linkUrl: profile.profileUrl,
                  linkIdentifier: profile.id,
                  provider: provider,
                  linkType: 'social',
                  linkSubType: 'primary',
                  caption: "Facebook",
                  isPublic: true
                });
              }
              if (provider === "twitter") {
                user.profileLinks.push({
                  linkUrl: "https://twitter.com/" + profile.username,
                  linkIdentifier: profile.username,
                  provider: provider,
                  linkType: 'social',
                  linkSubType: 'primary',
                  caption: "Twitter",
                  isPublic: true
                });
              }
              emails = [];
              if (profile.emails && _.isArray(profile.emails)) {
                profile.emails = _.filter(profile.emails, function(x) {
                  return x.value && x.value.length > 3;
                });
                emails = _.map(profile.emails, function(x) {
                  return x.value;
                });
              }
              for (_k = 0, _len2 = emails.length; _k < _len2; _k++) {
                email = emails[_k];
                user.emails.push(new {
                  email: email.toLowerCase(),
                  isVerified: true,
                  sendNotifications: false
                });
              }
              if (user.emails.length > 0) {
                user.primaryEmail = user.emails[0].email.toLowerCase();
              }
              user.location = (_ref1 = profile._json) != null ? (_ref2 = _ref1.location) != null ? _ref2.name : void 0 : void 0;
              user.needsInit = !profile.username || !user.primaryEmail || user.primaryEmail.toLowerCase().indexOf("facebook.com") > 0;
              user.gender = profile.gender;
              user.timezone = (_ref3 = profile._json) != null ? _ref3.timezone : void 0;
              user.locale = (_ref4 = profile._json) != null ? _ref4.locale : void 0;
              user.verified = (_ref5 = profile._json) != null ? _ref5.verified : void 0;
              user.roles = ['user-needs-setup'];
              newIdentity = {
                provider: provider,
                key: profile.id,
                v1: v1,
                v2: v2,
                providerType: "oauth",
                username: user.username,
                displayName: user.displayName,
                profileImage: user.selectedUserImage
              };
              user.identities.push(newIdentity);
              return user.save(function(err) {
                if (err) {
                  return cb(err);
                }
                return cb(null, user, {
                  isNew: isNew
                }, newIdentity);
              });
            });
          }
        };
      })(this));
    };

    UserMethods.prototype._usernameFromProfile = function(profile) {
      return profile.username || '';
    };

    UserMethods.prototype._displayNameFromProfile = function(profile) {
      if (profile.displayName) {
        return profile.displayName;
      }
      if (profile.name && profile.name.givenName && profile.name.familyName) {
        return "" + profile.name.givenName + " " + profile.name.familyName;
      }
      if (profile.name && profile.name.familyName) {
        return profile.name.familyName;
      }
      return profile.username;
    };

    UserMethods.prototype._profileImageFromProfile = function(profile) {
      var e, raw;
      if (profile.username && profile.provider === "facebook") {
        return "https://graph.facebook.com/" + profile.username + "/picture";
      }
      if (profile.provider === 'twitter' && profile.photos && _.isArray(profile.photos) && profile.photos.length > 0) {
        return profile.photos[0].value;
      }
      if (profile.provider === 'instagram') {
        try {
          raw = JSON.parse(profile._raw);
          return raw.data.profile_picture;
        } catch (_error) {
          e = _error;
          return null;
        }
      }
      if (profile.provider === 'foursquare') {
        try {
          raw = JSON.parse(profile._raw);
          return raw.response.user.photo;
        } catch (_error) {
          e = _error;
          return null;
        }
      }
      return null;
    };


    /*
    Adds an identity to an existing user. In this version, it replaces an 
    existing provider of the same type.
    @param {String/ObjectId} userId the id of the user to add this identity to.
    @param {String} provider a provider string like "facebook" or "twitter".
    @param {String} v1 the key or access_token, depending on the type of provider
    @param {String} v2 the secret or refresh_token, depending on the type of provider
    @param {Object} profile The profile as defined here: http://passportjs.org/guide/user-profile.html
     */

    UserMethods.prototype.addIdentityToUser = function(userId, provider, v1, v2, profile, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!userId) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      if (!provider) {
        return cb(fnUnprocessableEntity(i18n.errorProviderRequired));
      }
      if (!v1) {
        return cb(fnUnprocessableEntity(i18n.errorV1Required));
      }
      if (!profile) {
        return cb(fnUnprocessableEntity(i18n.errorProfileRequired));
      }
      if (!(profile && profile.id)) {
        return cb(fnUnprocessableEntity(i18n.errorIdWithinProfileRequired));
      }
      userId = mongooseRestHelper.asObjectId(userId);
      provider = provider.toLowerCase();
      return this.models.User.findOne({
        _id: userId
      }, (function(_this) {
        return function(err, user) {
          var existing, newIdentity;
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
          }
          existing = _.find(user.identities, function(x) {
            return x.provider === provider;
          });
          if (existing) {
            existing.remove();
          }
          newIdentity = {
            provider: provider,
            key: profile.id,
            v1: v1,
            v2: v2,
            providerType: "oauth",
            username: _this._usernameFromProfile(profile),
            displayName: _this._displayNameFromProfile(profile),
            profileImage: _this._profileImageFromProfile(profile)
          };
          user.identities.push(newIdentity);
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user, newIdentity);
          });
        };
      })(this));
    };

    UserMethods.prototype.removeIdentityFromUser = function(userId, identityId, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!userId) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      if (!identityId) {
        return cb(fnUnprocessableEntity(i18n.errorIdentityIdRequired));
      }
      userId = mongooseRestHelper.asObjectId(userId);
      identityId = mongooseRestHelper.asObjectId(identityId);
      return this.models.User.findOne({
        _id: userId
      }, (function(_this) {
        return function(err, user) {
          var existing;
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
          }
          existing = user.identities.id(identityId);
          if (existing) {
            existing.remove();
          }
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user);
          });
        };
      })(this));
    };

    UserMethods.prototype.addRoles = function(userId, roles, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (_.isString(roles)) {
        roles = [roles];
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      if (!(roles && _.isArray(roles) && roles.length > 0)) {
        return cb(fnUnprocessableEntity(i18n.errorRolesRequired));
      }
      userId = mongooseRestHelper.asObjectId(userId);
      return this.models.User.findOne({
        _id: userId
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
          }
          user.roles = _.union(user.roles || [], roles);
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user.roles, user);
          });
        };
      })(this));
    };

    UserMethods.prototype.removeRoles = function(userId, roles, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (_.isString(roles)) {
        roles = [roles];
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      if (!(roles && _.isArray(roles) && roles.length > 0)) {
        return cb(fnUnprocessableEntity(i18n.errorRolesRequired));
      }
      userId = mongooseRestHelper.asObjectId(userId);
      return this.models.User.findOne({
        _id: userId
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
          }
          user.roles = _.difference(user.roles || [], roles);
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user.roles, user);
          });
        };
      })(this));
    };

    resetPasswordTokenLength = 10;

    UserMethods.prototype.resetPassword = function(_tenantId, email, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorEmailRequired));
      }
      return this.getByPrimaryEmail(_tenantId, email, (function(_this) {
        return function(err, user) {
          var newToken;
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + email));
          }
          newToken = passgen.create(resetPasswordTokenLength) + user._id.toString() + passgen.create(resetPasswordTokenLength);
          user.resetPasswordToken = {
            token: newToken,
            validTill: (new Date()).add({
              days: 1
            })
          };
          console.log("E");
          return user.save(function(err) {
            console.log("F");
            console.log("G");
            return cb(null, user, newToken);
          });
        };
      })(this));
    };

    UserMethods.prototype.resetPasswordToken = function(_tenantId, token, password, options, cb) {
      var userId;
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (!_tenantId) {
        return cb(fnUnprocessableEntity(i18n.errorTenantIdRequired));
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!token) {
        return cb(fnUnprocessableEntity(i18n.errorTokenRequired));
      }
      if (!password) {
        return cb(fnUnprocessableEntity(i18n.errorPasswordRequired));
      }
      userId = token.substr(resetPasswordTokenLength, token.length - 2 * resetPasswordTokenLength);
      userId = mongooseRestHelper.asObjectId(userId);
      return this._hashPassword(password, (function(_this) {
        return function(err, hash) {
          if (err) {
            return cb(err);
          }
          return _this.models.User.findOne({
            _id: userId
          }, function(err, user) {
            if (err) {
              return cb(err);
            }
            if (!user) {
              return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
            }
            if (!user.resetPasswordToken) {
              return cb(fnUnprocessableEntity(i18n.errorTokenRequired));
            }
            if ((user.resetPasswordToken.token || '').toLowerCase() !== token.toLowerCase()) {
              return cb(fnUnprocessableEntity(i18n.errorTokenInvalid));
            }
            if (!(user.resetPasswordToken.validTill && user.resetPasswordToken.validTill.isAfter(new Date()))) {
              return cb(fnUnprocessableEntity(i18n.errorValidTillFailed));
            }
            user.resetPasswordToken = null;
            user.password = hash;
            return user.save(function(err) {
              if (err) {
                return cb(err);
              }
              return cb(null, user);
            });
          });
        };
      })(this));
    };

    UserMethods.prototype.addEmail = function(userId, email, isValidated, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!userId) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorEmailRequired));
      }
      userId = mongooseRestHelper.asObjectId(userId);
      return this.models.User.findOne({
        _id: userId
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
          }
          user.emails = _.union(user.emails || [], [email]);
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user.emails, user);
          });
        };
      })(this));
    };

    UserMethods.prototype.removeEmail = function(userId, email, options, cb) {
      if (options == null) {
        options = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (_.isFunction(options)) {
        cb = options;
        options = {};
      }
      if (!userId) {
        return cb(fnUnprocessableEntity(i18n.errorUserIdRequired));
      }
      if (!email) {
        return cb(fnUnprocessableEntity(i18n.errorEmailRequired));
      }
      userId = mongooseRestHelper.asObjectId(userId);
      return this.models.User.findOne({
        _id: userId
      }, (function(_this) {
        return function(err, user) {
          if (err) {
            return cb(err);
          }
          if (!user) {
            return cb(Boom.notFound("" + i18n.prefixErrorCouldNotFindUser + " " + userId));
          }
          user.emails = _.difference(user.emails || [], [email]);
          return user.save(function(err) {
            if (err) {
              return cb(err);
            }
            return cb(null, user.emails, user);
          });
        };
      })(this));
    };

    return UserMethods;

  })();

}).call(this);

//# sourceMappingURL=user-methods.js.map
