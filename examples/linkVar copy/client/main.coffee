Session.setDefault('searchText', '')

{input, div, button} = React.DOM


[x, Input] = React.createClassFactory
  displayName: 'Input'
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
  propTypes:
    searchVar: React.PropTypes.instanceOf(ReactiveVar).isRequired
  render: ->
    (div {}, 
      (input {type:'text', placeholder:'search', valueLink:@linkVar(@props.searchVar)})
    )

[x, Search] = React.createClassFactory
  displayName: 'Search'
  mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
  getMeteorState:
    searchVar: -> @sessionVar('searchText')
  render: ->
    (div {},
      (Input {searchVar: @state.searchVar})
    )

[x, Main] = React.createClassFactory
  displayName: 'Main'
  mixins: [React.addons.PureRenderMixin]
  getInitialState: ->
    show: true
  toggleShow: ->
    @setState({show: not @state.show})
  render: ->
    (div {},
      (button {onClick: @toggleShow}, 'toggle')
      do =>
        if @state.show
          (Search())
    )

FlowRouter.route '/', 
  action: (params, queryParams) ->
    React.renderBody Main()