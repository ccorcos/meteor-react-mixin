Package.describe({
  name: "ccorcos:react-utils",
  version: "0.0.3",
  summary: "React utils for Meteor",
  git: "https://github.com/ccorcos/meteor-react-utils",
});


Package.onUse(function(api) {
  api.use([
    "ccorcos:react@0.0.1",
    "coffeescript@1.0.5",
    "reactive-var@1.0.4"
  ]);
  api.imply([
    "ccorcos:react",
    "reactive-var"
  ]);

  api.addFiles([
    "src/utils.coffee"
  ]);
});