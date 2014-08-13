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

      helper.store.admin.setup helper.accountId,'app1',"martin","password1","martin@wawrusch.com",scopes,null,null,{}, (err,app, user, token,createdScopes) ->
        return cb err if err
        should.exist app
        should.exist user
        should.exist token
        should.exist createdScopes

        app.should.have.property "accountId" # "52998e1c32e5724771000009"
        app.should.have.property "name","app1"
        app.should.have.property "createdAt"
        app.should.have.property "updatedAt"
        app.should.have.property "accessibleBy"
        app.should.have.property "tags"
        app.should.have.property "isDeleted",false
        app.should.have.property "createdByUserId" #, new ObjectId "52a88e9a294d90d020000009"
        app.should.have.property "_id"
        app.should.have.property "stats"
        app.stats.should.have.property "tokensRevoked",0
        app.stats.should.have.property "tokensGranted",0
        app.should.have.property "redirectUrls"
        app.should.have.property "clients"
        app.clients.should.have.lengthOf 1
        app.should.have.property "tosAcceptanceDate",null
        app.should.have.property "isPublished",false
        app.should.have.property "acceptTermsOfService",false
        app.should.have.property "description"
        app.should.have.property "scopes"
        app.scopes.should.have.lengthOf 4 #["admin","email","read","write"]

        console.log JSON.stringify(app)
        console.log JSON.stringify(user)
        console.log JSON.stringify(token)
        console.log JSON.stringify(createdScopes)

        cb()


