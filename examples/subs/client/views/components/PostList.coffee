
Item = React.createFactory(Ionic.Item)
{h2, p} = React.DOM

React.createClassFactory
  displayName: 'PostItem'
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]

  propTypes:
    postId: React.PropTypes.string.isRequired
    onClick: React.PropTypes.func

  getMeteorState:
    post: ->
      post = Posts.findOne(@rprops.postId.get())
      post.user = Meteor.users.findOne(post.userId)
      return post

  render: -> 
    console.log "PostItem render"
    (Item {onClick: @props.onClick},
      (h2 {}, @state.post.title)
      (p {}, @state.post.user.username)
    )

Icon = React.createFactory(Ionic.Icon)

React.createClassFactory
  displayName: 'LoadingItem'
  mixins: [React.addons.PureRenderMixin]

  render: -> 
    console.log "LoadingItem render"
    (Item {style:{textAlign:'center', borderBottom:0}}, 
      (Icon {icon:'load-b', spin:true, style:{fontSize:'25px'}})
    )


List = React.createFactory(Ionic.List)
{PostItem, LoadingItem} = React.factories

React.createClassFactory
  displayName: 'PostList'
  mixins: [React.addons.PureRenderMixin]

  propTypes:
    postIds: React.PropTypes.arrayOf(React.PropTypes.string).isRequired
    onClick: React.PropTypes.func
    loading: React.PropTypes.bool

  render: -> 
    console.log "PostList render"
    (List {}, 
      (@props.postIds.map (postId) =>
        (PostItem {key: postId, postId: postId, onClick: => @props.onClick(postId)})
      )
      do => 
        if this.props.loading
          (LoadingItem())
    )
