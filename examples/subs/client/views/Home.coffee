Body = React.createFactory(Ionic.Body)
Header = React.createFactory(Ionic.Header)
Title = React.createFactory(Ionic.Title)
Content = React.createFactory(Ionic.Content)

{h2, p} = React.DOM
{PostList, TabBar} = React.factories

React.createClassFactory
  displayName: "Home"
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]

  getMeteorState:
    postIds: -> 
      posts = Posts.find({}, {sort:{name: 1, date:-1}, fields:{_id:1}}).fetch()
      _.pluck posts, '_id'

  getMeteorSubs: ->
    Meteor.subscribe('posts', 10)

  render: ->
    console.log "render Home"
    (Body {},
      (Header {position:'header', color: 'positive'},
        (Title {}, 'Home')
      )
      (Content {header: true},
        (PostList {postIds: @state.postIds, loading: not @state.subsReady})
      )
    )

