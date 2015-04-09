# React Meteor


A Meteor Mixin for React

## Getting Started

    meteor add ccorcos:react-meteor

## API

### React.MeteorMixin

`React.MeteorMixin` allows you to tightly integrate Meteor with React. 

This mixin with convert any props into reactive variables `this.rprops` so you can use them with `getMeteorState` for fine-grained reactivity of the state. If a props is an instance of ReactiveVar, then it will be passed into rprops as you might expect.

```js
getMeteorState: {
  post() {
    return Posts.findOne(this.rprops.postId.get())
  }
}
```

Another convenience of this mixin is `this.linkVar` which is similar to [`this.linkState`](http://facebook.github.io/react/docs/two-way-binding-helpers.html) except it links an input to a ReactiveVar. This allows you to pass a reactive var as props to multiple components and both could change and reactively update to that ReactiveVar without having to handle all the piping in their common ancestor. `linkVar` will force a re-render even if the state or props don't change.

```coffee
React.createClassFactory
  displayName: 'Header'
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
  propTypes:
    searchVar: React.PropTypes.instanceOf(ReactiveVar).isRequired
  render: ->
    (div {},
      (input {type:'text', placeholder:'search', valueLink:@linkVar(@props.searchVar)})
    )

React.createClassFactory
  displayName: 'Results'
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
  propTypes:
    searchVar: React.PropTypes.instanceOf(ReactiveVar).isRequired
  getMeteorState:
    postIds: -> 
      filter = new RegExp(@rprops.searchVar.get(), 'ig')
      posts = Posts.find({title: filter}, {sort: {name:1, date:-1}, fields: {_id: 1}}).fetch()
      _.pluck posts, '_id'
  render: ->  
    (div {},
      @state.postIds.map (postId) ->
        (Post {key: postId, postId: postId})
    )

React.createClassFactory
  displayName: 'Search'
  getInitialState: ->
    searchVar: new ReactiveVar('')
  render: ->
    (div {},
      (Header {searchVar: @state.searchVar})
      (Results {searchVar: @state.searchVar})
    )
```

Another helpful function is `this.sessionVar` which creates a ReactiveVar that binds to a Session variable. This way, the state of your app will persist across hot-code pushes and the state of your components will be maintained between mounts and unmounts.

```coffee
React.createClassFactory
  displayName: 'Search'
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
  getMeteorState:
    searchVar: -> @sessionVar('searchText')
  render: ->
    # ...
```

`this.getSessionVars` is a helper which uses `this.sessionVar` to bind Session variables to `this.vars`. This happens before `getMeteorSubs` and `getMeteorState` so you can use `this.vars` within those functions. This does not bind anything to `this.state`. The purpose of this is entirely to separate the global Session namespace from the component-level namespace. For example, here we separate the the 'home.postsLimit' Session variable from `this.vars.postLimit`.

```coffee
  getSessionVars:
    postsLimit: 'home.postsLimit'

  getMeteorState:
    postIds: -> 
      posts = Posts.find({}, {sort:{name: 1, date:-1}, fields:{_id:1}}).fetch()
      _.pluck posts, '_id'
    canLoadMore: -> 
      @getMeteorState.postIds().length >= @vars.postsLimit.get()

  getMeteorSubs: ->
    sub = Meteor.subscribe('posts', @vars.postsLimit.get())
    return () -> sub.ready()
```

This mixin has `getMeteorSubs` which runs your subscriptions within an autorun so they will be automatically stopped once `componentWillUnmount` is called. You must return a reactive function that returns whether or not all subscriptions are ready. This will update the state variable `this.state.subsReady` and will block the component from re-rendering based on other state changes until subsReady is true. If you have multiple subscriptions, you should do something like this.

```coffee
  getMeteorSubs: ->
    sub1 = Meteor.subscribe('post', postId)
    sub2 = Meteor.subscribe('user', userId)
    return () -> 
      a = sub1.ready()
      b = sub2.ready()
      return a and b
```

This also works well with [`meteorhacks:subs-manager`](https://github.com/meteorhacks/subs-manager) or [`ccorcos:subs-cache`](https://github.com/ccorcos/meteor-subs-cache).

```coffee
subsCache = new SubsCache
  expireAter: 5
  cacheLimit: -1

# {clip}

  getMeteorSubs: ->
    subsCache.subscribe('post', postId)
    subsCache.subscribe('user', userId)
    # more subscriptions...
    subsCache.subscribe('comment', commentId)
    return () -> subsCache.ready() # returns ready if ALL are ready
```

### React.createClassFactory

`React.createClassFactory` creates a class as you could expect, but also uses the display name to add the class to a global `React.classes` object and uses `React.createFactory` to add a factory of that class to a global `React.factories` object. This way, you can conveniently access you different classes from different files without polluting your global namespace. `React.createClassFactory` returns an array where the first element is the class and the second element is the factory of that class. 

Factories are convenient if you don't want to use JSX and saves you from using `React.createElement` everywhere, especially for coffeescript. For example, in coffeescript, you might write like this.

```coffee
{Item} = React.factories
{h2, p} = React.DOM

React.createClassFactory
  # ...
  render: -> 
    (Item {onClick: @props.onClick},
      (h2 {}, @state.post.title)
      (p {}, @state.post.user.username)
    )
```

### React.renderBody
`React.renderBody` is a simple wrapper that renders to the body of the document. This works nicely with [`meteorhacks:flow-router`](https://github.com/meteorhacks/flow-router).

```js
FlowRouter.route('/', {
  action: function(params, queryParams) {
    Main = React.classes.Main
    React.renderBody(<Main/>)
  }
});
```

```coffee
FlowRouter.route '/', 
  action: (params, queryParams) ->
    Main = React.factories.Main
    React.renderBody Main()
```

## Examples

The best way to figure this stuff out is to check out the examples. You will also need to either clone my other repos parallel with this package (for the symlinks to work) or just remove the packages symlinks and download the packages from Atmosphere. I'll leave the symlinks though because it helps me debug.

## To Do

- fastRender (SSR)
