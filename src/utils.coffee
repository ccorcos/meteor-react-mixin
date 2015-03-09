React.classes = {}
React.factories = {}

# render to body helper
React.renderBody = (c) -> 
  React.render(c, document.body)

React.createClassFactory = (spec) ->
  c = React.createClass(spec)
  f = React.createFactory(c)

  name = spec.displayName

  if name
    React.classes[name] = c
    React.factories[name] = f

  return [c,f]

# MeteorMixin

###
Ex1:
  Post as title, stuff, and an array of commentIds
  CommentList takes a list of commentIds.
  Each comment gets a commentId and fetches the right one and renders it
  Lesson: We want to pass ids and look up with findOne, otherwise the reactivity will call anytime anything changes

Ex2:
  The search page has a search header with an input and a search results lists.
  Search page passes a reactive variable to search header which alters the reactive variable as it pleases
  Search results gets the search query reactive variable, and looks up the array of posts. and passes those id's down.
###

reactiveProps = (context) ->
  context.rprops = {}
  for propName, propValue of context.props
    if propValue instanceof ReactiveVar
      context.rprops[propName] = propValue
    else
      context.rprops[propName] = new ReactiveVar(propValue)

# a function like linkState but for reactive variables
linkVar = (reactiveVar) ->
  {
    value: reactiveVar.get()
    requestChange: (value) => 
      reactiveVar.set(value)
      @forceUpdate()
  }

# create a reactiveVar from a sessionVar to maintain state across code-pushes and component unmounts
sessionVar = (sessionString) ->
  if Meteor.isClient
    # bind the reactiveVar both ways
    x = new ReactiveVar(Session.get(sessionString))

    Tracker.autorun (c) =>
      @computations.push(c)
      value = Session.get(sessionString)
      unless c.firstRun
        x.set(value)

    Tracker.autorun (c) =>
      @computations.push(c)
      value = x.get()
      unless c.firstRun
        Session.set(sessionString, value)

    return x
  else
    console.warn "Not sure how to support Session variable binding on the server..."

React.MeteorMixin =


  componentWillMount: ->
    # Create an object of reactive variables for the props. We can use these in
    # getMeteorState to trigger state updates reactively when the props change.
    reactiveProps(this)
    @linkVar = linkVar.bind(this)

    # hold all computations so we can stop them in componentWillUnmount
    @computations = []

    @sessionVar = sessionVar.bind(this)

    # set the state based on getMeteorState
    # when server-side rendering, we don't need all this reactivity stuff.
    if @getMeteorState
      if Meteor.isClient
        # queue up all the state changes in partialState
        # and then all at once during afterFlush, we'll call setState
        partialState = {}
        initialState = {}
        @updateState = new Tracker.Dependency()

        # fine-grained reactivity
        for name,func of @getMeteorState
          do (name, func) =>
            Tracker.autorun (c) =>
              @computations.push(c)
              value = func.bind(this)()
              if c.firstRun
                initialState[name] = value
              else
                partialState[name] = value
                @updateState.changed()

        @setState(initialState)
        initialState = null
        
        # This is where we update the state all at once afterFlush.
        # However, during the initial page load, afterflush gets called
        # after componentWillMount and Tracker.flush doesnt work because
        # we're already flushing. So on firstRun, we set the state manually.
        Tracker.autorun (c) =>
          @computations.push(c)
          @updateState.depend()
          Tracker.afterFlush () =>
            if Object.keys(partialState).length > 0
              @setState(partialState)
              partialState = {}

      else
        partialState = {}
        for name,func of @getMeteorState
          partialState[name] = func.bind(this)()
        @setState(partialState)

    # start meteor subscriptions
    if @getMeteorSubs
      if Meteor.isClient
        Tracker.autorun (c) =>
          @computations.push(c)
          @getMeteorSubs()

  componentWillReceiveProps: (nextProps)->
    for propName, propValue of nextProps
      @rprops[propName].set(propValue)
    # make sure setState is called so there's only one re-render
    try
      Tracker.flush()
    

  componentWillUnmount: ->
    for c in @computations
      c.stop()
      c = null