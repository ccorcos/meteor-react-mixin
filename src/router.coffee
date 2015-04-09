
@Router = {}

@Router.routes = {}     # render functions
@Router.current = null  # route name
@Router.history = [{name:'/', args:[]}] # route history so we can call back()
# create a route
@Router.beforeHooks = []
@Router.before = (func) ->
  @beforeHooks.push(func)
@Router.route = (name, renderFunc) ->
  # save the render function so we can do some fancy virtual DOM
  # animations later if we want.
  @routes[name] = renderFunc
  # wrap Flow Router
  self = this
  FlowRouter.route name,
    middlewares: self.beforeHooks
    action: (args...) ->
      # if we are landing here for the first time
      # set the appropriate segue
      if self.current is null
        self.currentSegue = self.segues[null]?[name]
      # add route to history
      self.history.push({name, args})
      self.current = name
      # render to the document body
      React.render(renderFunc.apply(FlowRouter, args), document.body)

# Animation
@Router.mixin = {
  componentDidMount: ->
    # user the route name that this component applies to
    Router.componentDidMount(this)
}

@Router.segues = {}
@Router.segue = (obj) ->
  # from and to are the route names. They could
  # also be something like /post/:postId. Then
  # we have in an out animations for the top-level
  # component context
  # 
  # obj = 
  #   from: '/search'
  #   to: '/'
  #   in: (ctx) ->
  #   out: (ctx) ->
  unless obj.from of @segues
    @segues[obj.from] = {}
  @segues[obj.from][obj.to] = obj


@animating = false
@currentComponent = null
@currentSegue = null
@Router.componentDidMount = (context) ->
  # so we can animate it out on the next segue
  @currentComponent = context
  # initiate the current segue
  @currentSegue?.in context, => 
    @animating = false
    @currentSegue = null

@Router.go = (name, args...) ->
  if @animating
    # wait for animations to finish
    return
  prev = @current
  next = name
  @currentSegue = @segues[prev]?[next]
  # handle the segue
  if @currentSegue
    @animating = true
    @currentSegue.out @currentComponent, -> 
      FlowRouter.go.apply(FlowRouter, [name].concat(args))
  else
    FlowRouter.go.apply(FlowRouter, [name].concat(args))