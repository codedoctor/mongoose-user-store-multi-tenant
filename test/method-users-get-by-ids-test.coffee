should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId

sampleUsers = null

describe 'WHEN working with store.users.getByIds', ->

  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb

  it 'should exist', ->
    should.exist helper.store.users

  describe 'WHEN running against an empty database', ->
    describe 'WHEN invoking getByIds', ->
      it 'WITH empty parameters IT should return an empty list', (cb) ->
        helper.store.users.getByIds [], (err,result) ->
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
      helper.dumpCollection('users') ->
        cb()
    ###
    describe 'WHEN invoking getByIds', ->
      it 'WITH empty parameters IT should return an empty list', (cb) ->
        helper.store.users.getByIds [], (err,result) ->
          return cb err if err
          should.exist.result
          result.should.have.property "items"
          result.items.should.have.lengthOf 0
          cb()

      it 'WITH non existing object ids  IT should return an empty list', (cb) ->
        helper.store.users.getByIds sampleUsers.nonExistingUserIds(3), (err,result) ->
          return cb err if err
          should.exist.result
          result.should.have.property "items"
          result.items.should.have.lengthOf 0
          cb()

      it 'WITH partially non existing object ids  IT should return an only the matches', (cb) ->
        nonExisting = sampleUsers.nonExistingUserIds(3)
        existing = sampleUsers.existingUserIds(3)
        
        #helper.log _.union(nonExisting,existing)

        helper.store.users.getByIds _.union(nonExisting,existing), (err,result) ->
          return cb err if err
          should.exist.result
          result.should.have.property "items"
          result.items.should.have.lengthOf 3
          cb()

      it 'WITH valid duplicates IT should only return one', (cb) ->
        existing = sampleUsers.existingUserIds(3)
        existing.push existing[0]

        helper.store.users.getByIds existing, (err,result) ->
          return cb err if err
          should.exist.result
          result.should.have.property "items"
          result.items.should.have.lengthOf 3
          cb()

      it 'WITH valid object ids (not strings) IT should return those', (cb) ->
        existing = sampleUsers.existingUserIds(3)
        existing = _.map existing, (x) => new ObjectId(x)

        helper.store.users.getByIds existing, (err,result) ->
          return cb err if err
          should.exist.result
          result.should.have.property "items"
          result.items.should.have.lengthOf 3
          cb()

      ###
      NOTE: WE NEED TO ADD THIS, but no time today.
      it 'WITH invalid object ids it should return an argument error', (cb) ->
        invalid = ['hallo','frank']

        helper.store.users.getByIds invalid, (err,result) ->
          should.exist err
          # TODO: Ensure that this is the right kind of error
          cb()
      ###