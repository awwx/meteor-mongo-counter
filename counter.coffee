getRawMongoCollection = (collectionName) ->
  if MongoInternals?
    MongoInternals.defaultRemoteCollectionDriver().mongo._getCollection(collectionName)
  else
    Meteor._RemoteCollectionDriver.mongo._getCollection(collectionName)


getCounterCollection = ->
  getRawMongoCollection('awwx_mongo_counter')


callCounter = (method, args...) ->
  Counters = getCounterCollection()
  if Meteor._wrapAsync?
    Meteor._wrapAsync(_.bind(Counters[method], Counters))(args...)
  else
    future = new (Npm.require(Npm.require('path').join('fibers', 'future')))()
    Counters[method].call(Counters, args..., future.resolver())
    future.wait()


_deleteCounters = ->
  callCounter('remove', {}, {safe: true})


_incrementCounter = (counterName, amount = 1) ->
  newDoc = callCounter(
    'findAndModify',
    {_id: counterName},         # query
    null,                       # sort
    {$inc: {seq: amount}},      # update
    {new: true, upsert: true},  # options
  )                             # callback added by wrapAsync
  return newDoc.seq


_decrementCounter = (counterName, amount = 1) ->
  _incrementCounter(counterName, -amount)


_setCounter = (counterName, value) ->
  callCounter(
    'update',
    {_id: counterName},
    {$set: {seq: value}}
  )
  return


if Package?
  incrementCounter = _incrementCounter
  decrementCounter = _decrementCounter
  setCounter = _setCounter
  deleteCounters = _deleteCounters
else
  @incrementCounter = _incrementCounter
  @decrementCounter = _decrementCounter
  @setCounter = _setCounter
  @deleteCounters = _deleteCounters
