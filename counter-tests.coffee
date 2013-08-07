Tinytest.add 'autoincrement-counter', (test) ->
  deleteCounters()
  test.equal incrementCounter('foo'), 1
  test.equal incrementCounter('foo'), 2
  test.equal incrementCounter('foo'), 3
  test.equal incrementCounter('bar'), 1
