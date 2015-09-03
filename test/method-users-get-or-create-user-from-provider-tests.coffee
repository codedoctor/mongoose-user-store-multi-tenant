should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId
fixtures = require './support/fixtures'

sampleUsers = null

describe 'WHEN working with store.users.getByIds', ->

  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb

  it 'should exist', ->
    should.exist helper.store.users

  describe 'WHEN running against an empty database', ->
    describe 'WHEN invoking getOrCreateUserFromProvider', ->
      it 'WITH empty parameters IT should return an empty list', (cb) ->
        helper.store.users.getOrCreateUserFromProvider fixtures._tenantId,fixtures.providerNameSome,fixtures.accessTokenSome,fixtures.secretSome,fixtures.profileSome,roles: ['rolea','roleb'], (err,result) ->
          return cb err if err

          should.exist.result
          result.should.have.property('createdAt').be.a.Date
          result.should.have.property('updatedAt').be.a.Date
          result.updatedAt.should.equal result.createdAt
          result.should.have.property('title','').be.a.String
          result.should.have.property('displayName').be.a.String  #.with.lengthOf(26)
          result.should.have.property('username').be.a.String #.with.lengthOf(26)
          result.should.have.property('_tenantId')
          result._tenantId.toString().should.have.lengthOf(24)
          result.should.have.property('resourceLimits').be.an.Array #.lengthOf(0)
          result.should.have.property('isDeleted',false).be.a.Boolean
          result.should.have.property('deletedAt',null)
          result.should.have.property('description').be.a.String #.with.lengthOf(0)
          result.should.have.property('_id')
          result._id.toString().should.have.lengthOf(24)
          result.should.have.property('needsInit',true).be.a.Boolean
          result.should.have.property('onboardingState',null)
          result.should.have.property('roles').be.an.Array #.lengthOf(2)
          result.roles[0].should.equal "rolea"
          result.roles[1].should.equal "roleb"
          result.should.have.property('emails').be.an.Array #.lengthOf(0)
          result.should.have.property('userImages').be.an.Array #.lengthOf(0)
          result.should.have.property('profileLinks').be.an.Array #.lengthOf(0)
          result.should.have.property('identities').be.an.Array #.lengthOf(1)
          i = result.identities[0]
          i.should.have.property('provider','some').be.a.String
          i.should.have.property('key','52998e1c32e5724771000001').be.a.String
          i.should.have.property('v1','accesstokensome').be.a.String
          i.should.have.property('v2','secretsome').be.a.String
          i.should.have.property('_id')
          i._id.toString().should.have.lengthOf(24)

          i.should.have.property('displayName','fb52998e1c32e5724771000001').be.a.String
          i.should.have.property('username','fb52998e1c32e5724771000001').be.a.String
          i.should.have.property('providerType','oauth').be.a.String

          #console.log JSON.stringify(result,null,2)

          cb()
