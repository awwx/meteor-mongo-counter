Package.describe({
  name: 'konecty:mongo-counter',
  summary: "Atomic counters stored in MongoDB",
  version: "0.0.5_2",
  git: "https://github.com/Konecty/meteor-mongo-counter.git"
});

Package.onUse(function (api) {
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

Package.onTest(function(api) {
  api.use('coffeescript');
  api.use('tinytest');
  api.use('konecty:mongo-counter');
  api.addFiles('counter-tests.coffee', 'server');
});
