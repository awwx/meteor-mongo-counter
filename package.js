Package.describe({
  summary: "Autoincrementing sequence counters stored in MongoDB"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'mongo-livedata'], 'server');
  if (api.export) {
    api.export('incrementCounter', 'server');
    api.export('deleteCounters', 'server', {testOnly: true});
  }
  api.add_files('counter.coffee', 'server');
});

Package.on_test(function(api) {
  api.use(['coffeescript', 'tinytest', 'autoincrement-counter']);
  api.add_files('counter-tests.coffee', 'server');
});
