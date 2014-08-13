should = require 'should'
helper = require './support/helper'
_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId

sampleUsers = null
mongoHelper = require './support/mongo-helper'

describe 'testing admin', ->

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


      scopes = [
        {"name": "read", "description": "Allows read access to your data.", "developerDescription": "", "roles": ["public"]},
        {"name": "write", "description": "Allows write access to your data.", "developerDescription": "", "roles": ["public"]},
        {"name": "email", "description": "Allows access to your email address.", "developerDescription": "", "roles": ["public"]},
        {"name": "admin", "description": "Allows full admin access to the platform.", "developerDescription": "", "roles": ["admin"]}
      ]

      helper.store.admin.setup helper._tenantId,'app1',"martin","password1","martin@wawrusch.com",scopes,null,null,{}, (err,user) ->
        return cb err if err
        should.exist user

        cb()


