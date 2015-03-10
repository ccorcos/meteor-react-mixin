Body = React.createFactory(Ionic.Body)
Header = React.createFactory(Ionic.Header)
Title = React.createFactory(Ionic.Title)
Content = React.createFactory(Ionic.Content)

{h2, p} = React.DOM
{PostList, TabBar} = React.factories



N_POSTS = 1
Session.setDefault('home.postsLimit', N_POSTS)

React.createClassFactory
  displayName: "Home"
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]

  getMeteorState:
    postIds: -> 
      # create a dependancy on 
      # l = Session.get('home.postsLimit')
      console.log "postId changed"
      posts = Posts.find({}, {sort:{name: 1, date:-1}, fields:{_id:1}}).fetch()
      _.pluck posts, '_id'

  getMeteorSubs: ->
    CacheSubs.subscribe('posts', Session.get('home.postsLimit'))

  getMoreSubs: ->
    Session.set('home.postsLimit',  Session.get('home.postsLimit') + N_INC)

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


###

how does infinite scroll work between components?

always subscribe to the top 10 with Meteor.subscribe
use subs.subscribe to cache subscriptions and implement infinite scrolling

getMeteorSubs calls startSubs while enforcing initialState

getMoreSubs calls startSubs but doesnt care about initialState

InfiniteScroll
  checks when you hit the bottom
  checks if there arent anymore posts
  calls getMoreSubs if there are more

subs.clear() when app is closed (cordova)

###

