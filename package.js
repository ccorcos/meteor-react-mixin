Package.describe({
  name: "ccorcos:react-utils",
  version: "0.0.1",
  summary: "React utils for Meteor",
  git: "https://github.com/ccorcos/meteor-react-utils",
});


Package.onUse(function(api) {
  api.use([
    "ccorcos:react",
    "coffeescript",
    "reactive-var"
  ]);
  api.imply([
    "ccorcos:react",
    "reactive-var"
  ]);

  api.addFiles([
    "src/utils.coffee"
  ]);
});