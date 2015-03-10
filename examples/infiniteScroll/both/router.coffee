{Home} = React.factories

FlowRouter.route '/',
  action: (params) ->
    React.renderBody Home({})