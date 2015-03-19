Package.describe({
  summary: "Atomic counters stored in MongoDB"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'mongo-livedata'], 'server');
  if (api.export) {
    api.export('incrementCounter', 'server');
    api.export('decrementCounter', 'server');
    api.export('setCounter', 'server');
    api.export('deleteCounters', 'server', {testOnly: true});
  }
  api.add_files('counter.coffee', 'server');
});

Package.on_test(function(api) {
  api.use(['coffeescript', 'tinytest', 'mongo-counter']);
  api.add_files('counter-tests.coffee', 'server');
});
