###
Abstraction for our standard collection result

items: []
requestOffset: 0..n
requestCount: 1..n
totalCount: 0..n 

###
module.exports = class PageResult
  ###
  Initializes a new instance of page result.
  @param items [Array] the result array of this query.
  @param requestOffset [Number] the offset from the first element. Used for paging.
  @param requestCount [Number] the number of items requested, range 1..n, defaults to 20
  @param totalCount [Number] the total number of entities available, range 0..n 
  ###
  constructor: (@items = [], @totalCount = 0, @requestOffset = 0, @requestCount = 20) ->
    # nop


