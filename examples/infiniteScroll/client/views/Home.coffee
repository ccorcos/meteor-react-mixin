Body = React.createFactory(Ionic.Body)
Header = React.createFactory(Ionic.Header)
Title = React.createFactory(Ionic.Title)
Content = React.createFactory(Ionic.Content)
Item = React.createFactory(Ionic.Item)
List = React.createFactory(Ionic.List)
Icon = React.createFactory(Ionic.Icon)

{h2, p} = React.DOM
{PostItem, InfiniteScroll} = React.factories

N_POSTS = 20
N_INC = 5
N_MINUTES = 0.1

Session.setDefault('home.postsLimit', N_POSTS)

postsLimitTimerId = null
Tracker.autorun (c) ->
  postsLimit = Session.get('home.postsLimit')
  if postsLimit isnt N_POSTS
    # reset the posts after some time
    console.log "new timer"
    Meteor.clearTimeout(postsLimitTimerId)
    postsLimitTimerId = Meteor.setTimeout((()->
      console.log "reset"
      Session.set('home.postsLimit', N_POSTS)
      Meteor.clearTimeout(postsLimitTimerId)
    ), 1000*60*N_MINUTES)

# autorun with a timer up here to reset periodically
# subs manager should remove "expireIn" AFTER stop has been called!ca

React.createClassFactory
  displayName: "Home"
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]

  getSessionVars:
    postsLimit: 'home.postsLimit'

  getMeteorState:
    postIds: -> 
      posts = Posts.find({}, {sort:{name: 1, date:-1}, fields:{_id:1}}).fetch()
      _.pluck posts, '_id'
    canLoadMore: -> 
      @getMeteorState.postIds().length >= @vars.postsLimit.get()


  getMeteorSubs: ->
    CacheSubs.subscribe('posts', @vars.postsLimit.get())

  loadMore: (nItemsCurrent)->
    # postsLimit is periodically reset. if its reset but we have cached
    # posts, we want to increment based on the current number of items.
    console.log "load more"
    @vars.postsLimit.set(nItemsCurrent + N_INC)

  renderItems: (children, onScroll) -> 
    # make sure to add props!
    children.unshift({})   
    (Content {onScroll:onScroll, ref:'scrollable', header:true},
      List.apply(this, children)
    )
    
  renderItem: (item, onClick) ->
    (PostItem {onClick: onClick, postId: item, key: item})

  renderEmpty: () ->
    (Item {style:{textAlign:'center', border:0}},
      (p {}, 'There are no posts...')
    )

  renderLoading: () ->
    (Item {style:{textAlign:'center', borderBottom:0}}, 
      (Icon {icon:'load-b', spin:true, style:{fontSize:'25px'}})
    )

  clickPost: (post) ->
    console.log "clicked post", post

  render: ->
    console.log "render Home", @state.postIds.length
    (Body {},
      (Header {position:'header', color: 'positive'},
        (Title {}, 'Home')
      )
      (InfiniteScroll
        items: @state.postIds
        renderItems: @renderItems
        renderItem: @renderItem
        renderEmpty: @renderEmpty
        renderLoading: @renderLoading
        canLoadMore: @state.canLoadMore
        isLoading: not @state.subsReady
        loadMore: @loadMore
        onClick: @clickPost
        buffer: 50
      )
    )