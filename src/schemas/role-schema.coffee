mongoose = require 'mongoose'

module.exports = RoleSchema = new mongoose.Schema
    _tenantId:
      type: mongoose.Schema.ObjectId
      require: true
      index : true
    name:
      type : String
      default: ''
    description:
      type : String
      default: ''
    isInternal:
      type : Boolean
      default: false
  ,
    strict: true
    collection: 'identitymt.roles'

RoleSchema.index({ _tenantId: 1,name: 1 },{ unique: true, sparse: false} );
