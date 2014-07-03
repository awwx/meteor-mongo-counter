getRawMongoCollection = (collectionName) ->
  if MongoInternals?
    MongoInternals.defaultRemoteCollectionDriver().mongo._getCollection(collectionName)
  else
    Meteor._RemoteCollectionDriver.mongo._getCollection(collectionName)


getCounterCollection = (collectionName) ->
  getRawMongoCollection(collectionName)


callCounter = (method, collectionName, args...) ->
  Counters = getCounterCollection(collectionName)
  if Meteor._wrapAsync?
    Meteor._wrapAsync(_.bind(Counters[method], Counters))(args...)
  else
    future = new (Npm.require(Npm.require('path').join('fibers', 'future')))()
    Counters[method].call(Counters, args..., future.resolver())
    future.wait()


_deleteCounters = (collectionName) ->
  callCounter('remove', collectionName, {}, {safe: true})


_incrementCounter = (collectionName, counterName, amount = 1) ->
  newDoc = callCounter(
    'findAndModify',
    collectionName,
    {_id: counterName},         # query
    null,                       # sort
    {$inc: {seq: amount}},      # update
    {new: true, upsert: true},  # options
  )                             # callback added by wrapAsync
  return newDoc.seq


_decrementCounter = (collectionName, counterName, amount = 1) ->
  _incrementCounter(collectionName, counterName, -amount)


_setCounter = (collectionName, counterName, value) ->
  callCounter(
    'update',
    collectionName,
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
