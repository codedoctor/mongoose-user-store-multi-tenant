[![Build Status](https://travis-ci.org/codedoctor/mongoose-user-store-multi-tenant.svg?branch=master)](https://travis-ci.org/codedoctor/mongoose-user-store-multi-tenant)
[![Coverage Status](https://img.shields.io/coveralls/codedoctor/mongoose-user-store-multi-tenant.svg)](https://coveralls.io/r/codedoctor/mongoose-user-store-multi-tenant)
[![NPM Version](http://img.shields.io/npm/v/mongoose-user-store-multi-tenant.svg)](https://www.npmjs.org/package//mongoose-user-store-multi-tenant)
[![Dependency Status](https://gemnasium.com/codedoctor/mongoose-user-store-multi-tenant.svg)](https://gemnasium.com/codedoctor/mongoose-user-store-multi-tenant)
[![NPM Downloads](http://img.shields.io/npm/dm/mongoose-user-store-multi-tenant.svg)](https://www.npmjs.org/package/mongoose-user-store-multi-tenant)
[![Issues](http://img.shields.io/github/issues/codedoctor/mongoose-user-store-multi-tenant.svg)](https://github.com/codedoctor/mongoose-user-store-multi-tenant/issues)
[![API Documentation](http://img.shields.io/badge/API-Documentation-ff69b4.svg)](http://coffeedoc.info/github/codedoctor/mongoose-user-store-multi-tenant)

WARNING - THIS WILL BE REFACTORED (AUG 2014) - USE AT YOUR OWN RISK FOR NOW.

mongoose-user-store-multi-tenant
=================================

A bunch of mongoose schemas to implement user management in multi tenant scenarios.

## Key Concepts

* Each document in the database has a _tenantId. This _tenantId (formerly accountId) can be a fixed ObjectId in single tenant scenarios.

* You should not have to work with the schemas directly, instead we expose methods that encapsulate the most common use cases.


## See also

* [hapi-auth-bearer-mw](https://github.com/codedoctor/hapi-auth-bearer-mw)
* [hapi-loggly](https://github.com/codedoctor/hapi-loggly)
* [hapi-mandrill](https://github.com/codedoctor/hapi-mandrill)
* [hapi-mongoose-db-connector](https://github.com/codedoctor/hapi-mongoose-db-connector)
* [hapi-oauth-store-multi-tenant](https://github.com/codedoctor/hapi-oauth-store-multi-tenant)
* [hapi-routes-authorization-and-session-management](https://github.com/codedoctor/hapi-routes-authorization-and-session-management)
* [hapi-routes-oauth-management](https://github.com/codedoctor/hapi-routes-oauth-management)
* [hapi-routes-roles](https://github.com/codedoctor/hapi-routes-roles)
* [hapi-routes-status](https://github.com/codedoctor/hapi-routes-status)
* [hapi-routes-users-authorizations](https://github.com/codedoctor/hapi-routes-users-authorizations)
* [hapi-routes-users](https://github.com/codedoctor/hapi-routes-users)
* [hapi-user-store-multi-tenant](https://github.com/codedoctor/hapi-user-store-multi-tenant)

and additionally

* [api-pagination](https://github.com/codedoctor/api-pagination)
* [mongoose-oauth-store-multi-tenant](https://github.com/codedoctor/mongoose-oauth-store-multi-tenant)
* [mongoose-rest-helper](https://github.com/codedoctor/mongoose-rest-helper)
* [mongoose-user-store-multi-tenant](https://github.com/codedoctor/mongoose-user-store-multi-tenant)


## Contributing to mongoose-user-store-multi-tenant
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the package.json, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 - 2014 Martin Wawrusch See LICENSE for
further details.


