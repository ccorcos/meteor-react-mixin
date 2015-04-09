if Meteor.isClient
  Session.setDefault('a', 'a')
  Session.setDefault('b', 'b')

  {div, p, button} = React.DOM

  [Z, X] = React.createClassFactory
    displayName: 'X'
    mixins: [React.MeteorMixin, React.addons.PureRenderMixin]
    propTypes:
      sessionString: React.PropTypes.string.isRequired
    getMeteorState:
      sessionValue: -> Session.get(@props.sessionString)
      rSessionValue: -> 
        console.log "autorun rSessionValue" 
        Session.get(@rprops.sessionString.get())
    render: ->
      console.log "render"
      str1 = "non-reactive -> #{@state.sessionValue}"
      str2 = "reactive -> #{@state.rSessionValue}"
      (div {}, 
        (p {}, str1)
        (p {}, str2)
      )

  React.createClassFactory
    displayName: 'Main'
    getInitialState: ->
      {sessionString: 'a'}
    setA: ->
      @setState {sessionString: 'a'}
    setB: ->
      @setState {sessionString: 'b'}
    render: ->
      (div {},
        (button {onClick:@setA}, 'a')
        (button {onClick:@setB}, 'b')
        (X {sessionString:@state.sessionString})
      )

  FlowRouter.route '/', 
    action: (params, queryParams) ->
      Main = React.factories.Main
      React.renderBody Main()