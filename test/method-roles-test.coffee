should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId

sampleUsers = null
mongoHelper = require './support/mongo-helper'

describe 'testing roles', ->

  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb

  it 'should exist', ->
    should.exist helper.store.roles

  describe 'WHEN creating a role', ->
    it 'SHOULD CREATE ONE', (cb) ->
      data =
        name : "role1"
        description: "desc1"
        isInternal : false

      helper.store.roles.create helper.accountId, data,{}, (err,result) ->
        return cb err if err
        should.exist result
        result.should.have.property "name","role1"
        result.should.have.property "description","desc1"
        result.should.have.property "isInternal",false
        cb()

    it 'SHOULD NOT CREATE DUPLICATES', (cb) ->
      data =
        name : "role1"
        description: "desc1"
        isInternal : false

      helper.store.roles.create helper.accountId, data,{}, (err,result) ->
        should.exist err
        cb()


