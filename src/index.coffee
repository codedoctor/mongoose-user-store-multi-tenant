
Store = require './store'

module.exports =
  Store: Store
  store: (settings = {}) ->
    new Store(settings)