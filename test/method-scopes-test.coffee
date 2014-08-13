should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId

sampleUsers = null
mongoHelper = require './support/mongo-helper'

describe 'testing scopes', ->

  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb

  it 'should exist', ->
    should.exist helper.store.oauthScopes

  describe 'WHEN creating a scope', ->
    it 'SHOULD CREATE ONE', (cb) ->
      data =
        name : "scope1"
        description: "desc1"
        developerDescription: "ddesc1"
        roles: ['read']

      helper.store.oauthScopes.create helper.accountId, data,{}, (err,result) ->
        return cb err if err
        should.exist result
        result.should.have.property "name","scope1"
        result.should.have.property "description","desc1"
        result.should.have.property "developerDescription","ddesc1"
        cb()

    it 'SHOULD NOT CREATE DUPLICATES', (cb) ->
      data =
        name : "scope1"
        description: "desc1"
        developerDescription: "ddesc1"
        roles: ['read']

      helper.store.oauthScopes.create helper.accountId, data,{}, (err,result) ->
        should.exist err
        cb()


