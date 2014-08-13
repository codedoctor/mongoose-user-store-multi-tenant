[![Build Status](https://travis-ci.org/codedoctor/mongoose-identity-store-multi-tenant.svg?branch=master)](https://travis-ci.org/codedoctor/mongoose-identity-store-multi-tenant)
[![Coverage Status](https://img.shields.io/coveralls/codedoctor/mongoose-identity-store-multi-tenant.svg)](https://coveralls.io/r/codedoctor/mongoose-identity-store-multi-tenant)
[![NPM Version](http://img.shields.io/npm/v/mongoose-identity-store-multi-tenant.svg)](https://www.npmjs.org/package/mongoose-identity-store-multi-tenant)
[![Dependency Status](https://gemnasium.com/codedoctor/mongoose-identity-store-multi-tenant.svg)](https://gemnasium.com/codedoctor/mongoose-identity-store-multi-tenant)


TODO:

* add missing tests

* use mongooserest where possible (entity, users, oauth-auth)
* look into refresh token / token generation - storgate (reuse tokens)
* remove expired grants / tokens - expose as function here and run in the server.
* document

mongoose-identity-store-multi-tenant
===========================

npm install mongoose-identity-store-multi-tenant

A bunch of mongoose schemas to implement identity management (users, accesstokens, oauth apps) in multi tenant scenarios

This is a work in progress, and some indexes need to be defined. You have been warned

## Release Notes
### 0.3.22
complete cleanup, signature overhaul.

### 0.3.5
sarcasm: exporting the Role schema might be helpful too.

### 0.3.4
exposed role management methods

### 0.3.3
updated versions
allow for models to be created from connections

### 0.3.2
Bug fix: On creation of a facebook account that has an invalid email address don't blow up.
Reason: If a user has a facebook account associated with an invalid address facebook returns a bogus record...

### 0.3.1
Added autoIndex option to store creation, defaults to true. Updated dependencies

### 0.3.0
Bumped some of deps up, especially mongoose

### 0.2.7
Added retrieval of users by usernames

### 0.2.6
Added lookup method for fast mention lookup to users.

### 0.2.5
bcrypt update, fixes memory leak or so they say

### 0.2.4
Added tests, and getByIds

### 0.2.3
destroy paranoid users too

### 0.2.2
added user.destroy

### 0.2.0
* First version

## Stuff

npm test
npm run-script docs

node_modules/.bin/grunt                   # Starts the watch & test run
node_modules/.bin/grunt coffee            # Compiles the coffeescript

node_modules/.bin/grunt release
node_modules/.bin/grunt release:minor
node_modules/.bin/grunt release:major



## Contributing to mongoose-identity-store
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the package.json, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Martin Wawrusch See LICENSE for
further details.


