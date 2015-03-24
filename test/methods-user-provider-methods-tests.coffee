should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId
fixtures = require './support/fixtures'

sampleUsers = null

describe 'methods/user-provider-methods', ->

  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb


  describe 'store', ->
    it 'should expose userProviders', ->
      should.exist helper.store.userProviders

  describe 'invoking getUserFromProvider with no prior users', ->
    it 'should return no error, and no user', (cb) ->
      helper.store.userProviders.getUserFromProvider fixtures._tenantId,fixtures.providerNameSome,'abckey',null, (err,userResult) ->
        return cb err if err
        should.not.exist userResult
        cb null


  describe 'invoking getUserFromProvider with a prior user', ->
    before (cb) ->
      helper.store.users.getOrCreateUserFromProvider fixtures._tenantId,fixtures.providerNameSome,fixtures.accessTokenSome,fixtures.secretSome,fixtures.profileSome,roles: ['rolea','roleb'], (err,result) ->
        return cb err if err
        cb null

    it 'should return a user', (cb) ->
      helper.store.userProviders.getUserFromProvider fixtures._tenantId,fixtures.providerNameSome,fixtures.profileSome.id,null, (err,userResult) ->
        return cb err if err

        should.exist.userResult
        userResult.should.have.property('createdAt').be.a.Date
        userResult.should.have.property('updatedAt').be.a.Date
        userResult.should.have.property('title','').be.a.String
        userResult.should.have.property('displayName').be.a.String.with.lengthOf(26)
        userResult.should.have.property('username').be.a.String.with.lengthOf(26)
        userResult.should.have.property('_tenantId')
        userResult._tenantId.toString().should.have.lengthOf(24)
        userResult.should.have.property('resourceLimits').be.an.Array.lengthOf(0)
        userResult.should.have.property('isDeleted',false).be.a.Boolean
        userResult.should.have.property('deletedAt',null)
        userResult.should.have.property('description').be.a.String.with.lengthOf(0)
        userResult.should.have.property('_id')
        userResult._id.toString().should.have.lengthOf(24)
        userResult.should.have.property('needsInit',true).be.a.Boolean
        userResult.should.have.property('onboardingState',null)
        userResult.should.have.property('roles').be.an.Array.lengthOf(2)
        userResult.roles[0].should.equal "rolea"
        userResult.roles[1].should.equal "roleb"
        userResult.should.have.property('emails').be.an.Array.lengthOf(0)
        userResult.should.have.property('userImages').be.an.Array.lengthOf(0)
        userResult.should.have.property('profileLinks').be.an.Array.lengthOf(0)
        userResult.should.have.property('identities').be.an.Array.lengthOf(1)
        i = userResult.identities[0]
        i.should.have.property('provider','some').be.a.String
        i.should.have.property('key','52998e1c32e5724771000001').be.a.String
        i.should.have.property('v1','accesstokensome').be.a.String
        i.should.have.property('v2','secretsome').be.a.String
        i.should.have.property('_id')
        i._id.toString().should.have.lengthOf(24)

        i.should.have.property('displayName','fb52998e1c32e5724771000001').be.a.String
        i.should.have.property('username','fb52998e1c32e5724771000001').be.a.String
        i.should.have.property('providerType','oauth').be.a.String

        #console.log JSON.stringify(userResult,null,2)

        cb()
