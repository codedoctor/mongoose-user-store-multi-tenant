should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId

sampleUsers = null
mongoHelper = require './support/mongo-helper'

describe 'WHEN working with store.users.lookup', ->

  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb

  it 'should exist', ->
    should.exist helper.store.users.lookup

  describe 'WHEN running against an empty database', ->
    describe 'WHEN invoking lookup', ->
      it 'WITH empty parameters IT should return an empty list', (cb) ->
        helper.store.users.lookup helper._tenantId, "a",{}, (err,result) ->
          return cb err if err
          should.exist.result
          result.should.have.property "items"
          result.items.should.have.lengthOf 0
          cb()

  describe 'WHEN running against a sample database', ->
    it 'SETTING UP SAMPLE', (cb) ->
      sampleUsers = helper.addSampleUsers cb

    ###
    it "DUMP", (cb) ->
      mongoHelper.dumpCollection 'identitymt.users', cb
    ###
  describe 'WHEN invoking lookup', ->
    it 'WITH empty parameters IT should return a full list', (cb) ->
      helper.store.users.lookup helper._tenantId, '',{}, (err,result) ->
        return cb err if err
        should.exist.result
        result.should.have.property "items"
        result.items.should.have.lengthOf 10
        cb()

    it 'WITH searching for Al IT should return a list of 10 users', (cb) ->
      helper.store.users.lookup helper._tenantId, 'Al',{}, (err,result) ->
        return cb err if err
        should.exist.result
        result.should.have.property "items"
        result.items.should.have.lengthOf 10
        cb()

    it 'WITH searching for Al and limit 5 IT should return a list of 5 users', (cb) ->
      helper.store.users.lookup helper._tenantId, 'Al',{limit : 5}, (err,result) ->
        return cb err if err
        should.exist.result
        result.should.have.property "items"
        result.items.should.have.lengthOf 5
        cb()

