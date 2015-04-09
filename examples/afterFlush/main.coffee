if Meteor.isClient
  Session.setDefault('a', 1)
  Session.setDefault('b', 2)

  {div, p, button} = React.DOM

  React.createClassFactory
    displayName: 'Main'
    mixins: [React.MeteorMixin]
    getMeteorState:
      a: -> Session.get('a')
      b: -> Session.get('b')
    inc: ->
      Session.set('a', Session.get('a') + 1)
      Session.set('b', Session.get('b') + 1)
    render: ->
      console.log "render"
      (div {},
        (p {},
          "#{@state.a} + #{@state.b} = #{@state.a + @state.b}"
        )
        (p {},
          (button {onClick:@inc}, "inc")
        )
      )

  FlowRouter.route '/', 
    action: (params, queryParams) ->
      Main = React.factories.Main
      React.renderBody Main()