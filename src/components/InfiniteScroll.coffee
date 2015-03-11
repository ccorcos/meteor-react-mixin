
React.createClassFactory
  displayName: 'InfiniteScroll'

  propTypes:
    items:         React.PropTypes.array.isRequired
    renderItems:   React.PropTypes.func.isRequired
    renderItem:    React.PropTypes.func.isRequired
    renderEmpty:   React.PropTypes.func.isRequired
    renderLoading: React.PropTypes.func
    canLoadMore:   React.PropTypes.bool.isRequired
    isLoading:     React.PropTypes.bool.isRequired
    loadMore:      React.PropTypes.func
    onClick:       React.PropTypes.func
    buffer:        React.PropTypes.number

  getDefaultProps: ->
    buffer: 300

  getInitialState: ->
    isLoading: @props.isLoading

  componentWillReceiveProps: (newProps) ->
    if 'isLoading' of newProps
      if newProps.isLoading isnt @state.isLoading
        @setState({isLoading: newProps.isLoading})

  shouldComponentUpdate: (nextProps, nextState) ->
    # no need to re-render if isLoading changes.
    (not _.isEqual(_.omit(@props, 'isLoading'), _.omit(nextProps, 'isLoading')))

  onScroll: (e) ->
    x = @refs.scrollable.getDOMNode()
    d = x.scrollHeight - (x.scrollTop + x.clientHeight)
    if d < @props.buffer and not @state.isLoading
      @props.loadMore?(@props.items.length)
      @setState({isLoading: true})
    
  render: ->
    args = []
    if @props.items.length is 0 and not @props.canLoadMore
      args.push(@props.renderEmpty())
    else
      args.push(@props.items.map((item) => @props.renderItem(item, (() => @props.onClick?(item)) )))
    if @props.canLoadMore
      args.push(@props.renderLoading())

    @props.renderItems(args, @onScroll)
    