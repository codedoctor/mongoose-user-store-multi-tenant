_ = require 'underscore'
should = require 'should'
mongoskin = require 'mongoskin'
mongoose = require 'mongoose'
ObjectId = require('mongoose').Types.ObjectId

helper = require './helper'

class MongoHelper
  constructor: () ->
    @mongo = mongoskin.db helper.database, safe:false


  mongoCount: (name, cb = ->) =>
    @mongo.collection(name).count cb

  mongoFindOne: (name, id, cb = ->) =>
    id = new ObjectId id.toString()

    @mongo.collection(name).findOne _id : id , (err, item) =>
      return cb err if err
      # Leave stuff in here for logging later.
      cb null, item

  mongoFindFirst: (name, cb = ->) =>
    @mongo.collection(name).findOne {} , (err, item) =>
      return cb err if err
      cb null, item

  dumpRequestHeaders: (req, cb = ->) =>
    console.log "==========================  REQUEST HEADERS          =========================="
    for key in _.keys req.headers
      console.log "#{key} : #{req.headers[key]}"
    console.log "--------------------------------------------------------------------------------"
    cb null

  dumpResponseHeaders: (res, cb = ->) =>
    console.log "==========================  RESPONSE HEADERS          =========================="
    for key in _.keys res.headers
      console.log "#{key} : #{res.headers[key]}"
    console.log "--------------------------------------------------------------------------------"
    cb null

  dumpOne: (name, id, cb = ->) =>
    id = new ObjectId id.toString()
    @mongo.collection(name).findOne _id : id , (err, item) =>
      return cb err if err
      console.log "========================== DUMPING #{name} FOR #{id}  =========================="
      console.log JSON.stringify(item)
      console.log "--------------------------------------------------------------------------------"
      cb null

  dumpCollection: (name, cb = ->) =>
    console.log "========================== DUMPING #{name} =========================="
    @mongo.collection(name).find({}).toArray (err, items) =>    
      return cb err if err
      if items
        _.each items, (item) =>
          console.log JSON.stringify(item)
          console.log "-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
      else
        console.log "NO ITEMS"
      console.log "---------------------------------------------------------------------"
      cb null


module.exports = new MongoHelper()
