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

reactiveProps = () ->
  @rprops = {}
  for propName, propValue of @props
    if propValue instanceof ReactiveVar
      @rprops[propName] = propValue
    else
      @rprops[propName] = new ReactiveVar(propValue)

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

# This function binds sessionVars to the this.vars object. This all happens before getMeteorSubs or getMeteorState
# This is convenient because it allows you to bind a local namespace to a global Session namespace. This does not
# reactively update the state though. This is strictly a helper for namespacing
sessionVars = (obj) ->
  @vars = {}
  for name, sessionString of obj
    @vars[name] = @sessionVar(sessionString)
    
startMeteorSubs = ->
  if @getMeteorSubs
    # run in reactive computation to stop the subscription(s) when theyre done
    Tracker.autorun (c) =>
      @computations.push(c)
      # getMeteorSubs should return a reactive function to tell us if the sub(s) are ready
      readyFunc = @getMeteorSubs()
      # reactively update the subsReady state
      Tracker.autorun =>   
        ready = true         
        try
          ready = readyFunc()
        catch e
          console.warn("Did you forget to return a ready function from getMeteorSubs?")
        if c.firstRun
          # update the initialState appropriately
          @initialState?.subsReady = ready
        else
          # if the readiness changes, then update the state
          # if a sub starts and finished before an entire flush cycle,
          # then the state never updates, so we have to check if there are other updates
          if @state.subsReady != ready or Object.keys(@partialState).length > 0
            @partialState.subsReady = ready
            @updateState.changed()

startMeteorState = ->
  if Meteor.isClient
    # set the state based on getMeteorState
    if @getMeteorState
      # queue up all the state changes in partialState
      # and then all at once during afterFlush, we'll call setState
      for name, func of @getMeteorState
        # fine-grained reactivity
        do (name, func) =>
          Tracker.autorun (c) =>
            @computations.push(c)
            value = func.bind(this)()
            if c.firstRun
              @initialState?[name] = value
            else
              @partialState[name] = value
              @updateState.changed()
  else
    # server
    for name,func of @getMeteorState
      @initialState[name] = func.bind(this)()

React.MeteorMixin =
  componentWillMount: ->
    # Create an object of reactive variables for the props. We can use these in
    # getMeteorState to trigger state updates reactively when the props change.
    reactiveProps.bind(this)()
    @linkVar = linkVar.bind(this)
    # hold all computations so we can stop them in componentWillUnmount
    @computations = []
    @sessionVar = sessionVar.bind(this)

    @sessionVars = sessionVars.bind(this)
    @sessionVars(@getSessionVars)

    # on firstRun, we set the initial state
    @initialState = {}
    # partial state is queued and run afterFlush
    @partialState = {}
    # an array of all subs
    @subs = []

    if Meteor.isClient
      @updateState = new Tracker.Dependency()
      @subsDep = new Tracker.Dependency()

    @startMeteorState = startMeteorState.bind(this)
    @startMeteorState()

    @startMeteorSubs = startMeteorSubs.bind(this)
    @startMeteorSubs()

    # This is where we update the state all at once afterFlush.
    # However, during the initial page load, afterflush gets called
    # after componentWillMount and Tracker.flush doesnt work because
    # we're already flushing. So on firstRun, we set the state manually.
    Tracker.autorun (c) =>
      @computations.push(c)
      @updateState.depend()
      Tracker.afterFlush () =>
        if Object.keys(@partialState).length > 0
          if (@initialState?.subsReady or @partialState.subsReady or @state?.subsReady) and (@partialState.subsReady isnt false)
            # hold off on all rerenders while subscription waiting.
            # this way we dont get a bunch od re-renders while subscriptions
            # are coming in
            @setState(@partialState)
            @partialState = {}


    # set initial state if there is something to set
    if Object.keys(@initialState).length > 0
      @setState(@initialState)
    @initialState = null


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