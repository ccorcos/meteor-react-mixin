# React Meteor Utils

This package contains a React Mixin and some utilies for using React with Meteor.

## Getting Started

    meteor add ccorcos:react
    meteor add ccorcos:react-utils

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

Another convenience of this mixin is `this.linkVar` which is similar to [`this.linkState`](http://facebook.github.io/react/docs/two-way-binding-helpers.html) except it links an input to a ReactiveVar. This allows you to pass a reactive var as props to multiple components and both could change and reactively update to that ReactiveVar without having to handle all the piping in their common ancestor.

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

This mixin has `getMeteorSubs` which runs your subscriptions within an autorun so they will be automatically stopped once `componentWillUnmount` is called. There is also a `this.subsReady` state variable that will be true once all subscriptions are ready. This also blocks the component from re-rendering until the subscriptions are ready. This prevents re-renders as subscriptions incrementally come in.

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

### InfiniteScroll

This package also has a convenient infinitely scrolling component. Lets go through the props one by one.

    items:         React.PropTypes.array.isRequired

An array of items to render

    renderItem:    React.PropTypes.func.isRequired

A function that accepts one item and an onClick function and renders the item with the onClick prop hooked up.

    renderItems:   React.PropTypes.func.isRequired

A function that accepts an array of children and an onScroll function. It creates a scrollable div with a "scrollable" ref along with onScroll prop and renders the chilren inside.

    renderEmpty:   React.PropTypes.func.isRequired
    renderLoading: React.PropTypes.func

Renders an empty / loading "item".

    canLoadMore:   React.PropTypes.bool.isRequired

If there are more items that can be loaded.

    isLoading:     React.PropTypes.bool.isRequired

If the subs aren't ready yet.

    loadMore:      React.PropTypes.func

A function to load more. Here its easiest to update a session variable that reactively updates the subscription.

    onClick:       React.PropTypes.func

If an item is clicked, this function is called with the item.

    buffer:        React.PropTypes.number

The number of pixels from the bottom when loadMore gets called.

## Examples

The best way to figure this stuff out is to check out the examples. You will also need to either clone my other repos parallel with this package (for the symlinks to work) or just remove the packages symlinks and download the packages from Atmosphere. I'll leave the symlinks though because it helps me debug.

## To Do

- fastRender (SSR)
