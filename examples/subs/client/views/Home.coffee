
{h2, p, div} = React.DOM
{PostList, TabBar} = React.factories

React.createClassFactory
  displayName: "Home"
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]

  getMeteorState:
    postIds: -> 
      posts = Posts.find({}, {sort:{name: 1, date:-1}, fields:{_id:1}}).fetch()
      _.pluck posts, '_id'

  getMeteorSubs: ->
    sub = Meteor.subscribe('posts', 10)
    return () -> sub.ready()

  render: ->
    console.log "render Home"
    (div {},
      (div {header: true},
        (PostList {postIds: @state.postIds})
      )
    )

