
path = Npm.require('path')
Future = Npm.require(path.join('fibers', 'future'))


getRawMongoCollection = (collectionName) ->
  if MongoInternals?
    MongoInternals.defaultRemoteCollectionDriver().mongo._getCollection(collectionName)
  else
    Meteor._RemoteCollectionDriver.mongo._getCollection(collectionName)


getCounterCollection = ->
  getRawMongoCollection('awwx_autoincrement_counter')


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


_incrementCounter = (counterName) ->
  newDoc = callCounter(
    'findAndModify',
    {_id: counterName},         # query
    null,                       # sort
    {$inc: {seq: 1}},           # update
    {new: true, upsert: true},  # options
  )                             # callback added by wrapAsync
  return newDoc.seq


if Package?
  incrementCounter = _incrementCounter
  deleteCounters = _deleteCounters
else
  @incrementCounter = _incrementCounter
  @deleteCounters = _deleteCounters
