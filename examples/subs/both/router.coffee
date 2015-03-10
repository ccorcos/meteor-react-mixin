{Home, Settings} = React.factories

FlowRouter.route '/',
  action: (params) ->
    React.renderBody Home({})

FlowRouter.route '/settings',
  action: (params) ->
    React.renderBody Settings({})