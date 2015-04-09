
{div, h2, p} = React.DOM

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
    (div {onClick: @props.onClick},
      (h2 {}, @state.post.title)
      (p {}, @state.post.user.username)
    )

{PostItem} = React.factories

React.createClassFactory
  displayName: 'PostList'
  mixins: [React.addons.PureRenderMixin]

  propTypes:
    postIds: React.PropTypes.arrayOf(React.PropTypes.string).isRequired
    onClick: React.PropTypes.func

  render: -> 
    console.log "PostList render"
    (div {}, 
      (@props.postIds.map (postId) =>
        (PostItem {key: postId, postId: postId, onClick: => @props.onClick?(postId)})
      )
    )
