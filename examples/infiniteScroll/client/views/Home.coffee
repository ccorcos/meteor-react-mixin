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

Session.setDefault('postsLimit', N_POSTS)

postLimitTimerId = null
Tracker.autorun (c) ->
  postsLimit = Session.get('postsLimit')
  if postsLimit isnt N_POSTS
    # reset the posts after some time
    console.log "new timer"
    Meteor.clearTimeout(postLimitTimerId)
    postLimitTimerId = Meteor.setTimeout((()->
      console.log "reset"
      Session.set('postsLimit', N_POSTS)
      Meteor.clearTimeout(postLimitTimerId)
    ), 1000*60*N_MINUTES)

# autorun with a timer up here to reset periodically
# subs manager should remove "expireIn" AFTER stop has been called!ca

React.createClassFactory
  displayName: "Home"
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]

  getMeteorState:
    postIds: -> 
      posts = Posts.find({}, {sort:{name: 1, date:-1}, fields:{_id:1}}).fetch()
      _.pluck posts, '_id'

  getMeteorSubs: ->
    CacheSubs.subscribe('posts', Session.get('postsLimit'))

  loadMore: (nItemsCurrent)->
    # postsLimit is periodically reset. if its reset but we have cached
    # posts, we want to increment based on the current number of items.
    console.log "load more"
    Session.set('postsLimit',  nItemsCurrent + N_INC)

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
        canLoadMore: @state.postIds.length >= Session.get('postsLimit')
        isLoading: not @state.subsReady
        loadMore: @loadMore
        onClick: @clickPost
        buffer: 50
      )
    )