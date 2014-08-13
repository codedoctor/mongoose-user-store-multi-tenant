
/*
Abstraction for our standard collection result

items: []
requestOffset: 0..n
requestCount: 1..n
totalCount: 0..n
 */

(function() {
  var PageResult;

  module.exports = PageResult = (function() {

    /*
    Initializes a new instance of page result.
    @param items [Array] the result array of this query.
    @param requestOffset [Number] the offset from the first element. Used for paging.
    @param requestCount [Number] the number of items requested, range 1..n, defaults to 20
    @param totalCount [Number] the total number of entities available, range 0..n
     */
    function PageResult(items, totalCount, requestOffset, requestCount) {
      this.items = items != null ? items : [];
      this.totalCount = totalCount != null ? totalCount : 0;
      this.requestOffset = requestOffset != null ? requestOffset : 0;
      this.requestCount = requestCount != null ? requestCount : 20;
    }

    return PageResult;

  })();

}).call(this);

//# sourceMappingURL=page-result.js.map
