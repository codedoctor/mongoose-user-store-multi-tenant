_ = require 'underscore'
should = require 'should'

helper = require './support/helper'
mongoHelper = require './support/mongo-helper'

sampleUsers = null

describe 'testing admin functions', ->
  before (cb) ->
    helper.start null, cb

  after (cb) ->
    helper.stop cb

  it 'should exist', ->
    should.exist helper.store.roles

  describe 'WHEN setting up an account', ->
    it 'SHOULD CREATE ONE', (cb) ->
      data =
        name : "role1"
        description: "desc1"
        isInternal : false

      helper.store.admin.setup helper._tenantId,"martin","password1","martin@wawrusch.com",null,{}, (err,user) ->
        return cb err if err
        should.exist user

        cb()


