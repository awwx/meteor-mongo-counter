Package.describe({
  name: 'konecty:mongo-counter',
  summary: "Atomic counters stored in MongoDB",
  version: "0.0.4",
  git: "https://github.com/Konecty/meteor-mongo-counter.git"
});

Package.on_use(function (api) {
  api.versionsFrom("METEOR@0.9.0");
  api.use(['coffeescript', 'mongo-livedata'], 'server');
  api.addFiles('counter.coffee', 'server');
  if (api.export) {
    api.export('incrementCounter', 'server');
    api.export('decrementCounter', 'server');
    api.export('setCounter', 'server');
    api.export('deleteCounters', 'server', {testOnly: true});
  }
});

Package.on_test(function(api) {
  api.use(['coffeescript', 'tinytest', "konecty:mongo-counter"]);
  api.addFiles('counter-tests.coffee', 'server');
});
