Package.describe({
  name: "ccorcos:react-utils",
  version: "0.0.8",
  summary: "React utils for Meteor",
  git: "https://github.com/ccorcos/meteor-react-utils",
});


Package.onUse(function(api) {
  api.use([
    "grove:react@0.1.1",
    "coffeescript@1.0.5",
    "reactive-var@1.0.4"
  ]);
  api.imply([
    "grove:react",
    "reactive-var"
  ], 'client');

  api.addFiles([
    "src/utils.coffee",
    "src/components/InfiniteScroll.coffee"
  ], 'client');
});