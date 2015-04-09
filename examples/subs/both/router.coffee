
FlowRouter.route '/',
  action: (params) ->
    {Home} = React.factories
    React.renderBody Home({})
