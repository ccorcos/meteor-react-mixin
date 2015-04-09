Posts = new Mongo.Collection('posts')

if Meteor.isServer
  Meteor.startup ->
    if Posts.find().count() is 0
      console.log "creating fake posts"

      for post in [0...50]
        Posts.insert
          title: Fake.sentence(3)
          date: Date.now()

if Meteor.isClient
  {input, div} = React.DOM
  
  [x, Header] = React.createClassFactory
    displayName: 'Header'
    mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
    propTypes:
      searchVar: React.PropTypes.instanceOf(ReactiveVar).isRequired
    render: ->
      console.log "render header"
      (div {}, 
        (input {type:'text', placeholder:'search', valueLink:@linkVar(@props.searchVar)})
      )

  [x, Post] = React.createClassFactory
    displayName: 'Results'
    mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
    propTypes:
      postId: React.PropTypes.string.isRequired
    getMeteorState:
      post: -> 
        Posts.findOne(@rprops.postId.get(), {fields:{title:1}})
    render: ->
      console.log "render post"
      (div {}, 
        @state.post.title
      )

  [x, Results] = React.createClassFactory
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
      console.log "render results"
      (div {},
        @state.postIds.map (postId) ->
          (Post {key: postId, postId: postId})
      )

  [x, Search] = React.createClassFactory
    displayName: 'Search'
    getInitialState: ->
      searchVar: new ReactiveVar('')
    render: ->
      console.log "render search"
      (div {},
        (Header {searchVar: @state.searchVar})
        (Results {searchVar: @state.searchVar})
      )

  FlowRouter.route '/', 
    action: (params, queryParams) ->
      React.renderBody Search()