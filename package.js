Package.describe({
  name: "ccorcos:react-meteor",
  version: "0.1.0",
  summary: "Meteor Mixin for React",
  git: "https://github.com/ccorcos/meteor-react-mixin",
});


Package.onUse(function(api) {
  api.use([
    "grove:react@0.1.1",
    "coffeescript@1.0.5",
    "reactive-var@1.0.4",
  ]);
  api.imply([
    "grove:react",
    "reactive-var"
  ], 'client');

  api.addFiles(["src/utils.coffee"], 'client');
});