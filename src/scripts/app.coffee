

React = require 'react'
Router = require 'react-router'
Promise = require 'bluebird'
_ = require 'underscore'
Immutable = require 'immutable'

routes = require './routes.coffee'
createReactRouterRoutes = require './utils/createReactRouterRoutes.coffee'
Timer = require './utils/Timer.coffee'

ApplicationActionCreators = require './actions/ApplicationActionCreators.coffee'
RouterActionCreators = require './actions/RouterActionCreators.coffee'


RoutesStore = require './stores/RoutesStore.coffee'
initializeData = require './initializeData.coffee'

###
  Bootstrap and start whole application
  appOptions:
    - data - initial data
    - rootNode - mount element
    - locationMode - hash or pushState location
###
startApp = (appOptions) ->

  initializeData(appOptions.data)

  ApplicationActionCreators.receiveApplicationData(
    sapiUrl: appOptions.data.sapi.url
    sapiToken: appOptions.data.sapi.token
    organizations: appOptions.data.organizations
    kbc: appOptions.data.kbc
  )

  RouterActionCreators.routesConfigurationReceive(routes)

  router = Router.create(
    routes: createReactRouterRoutes(_.extend {}, routes,
      path: appOptions.data.kbc.projectBaseUrl
    )
    location: if appOptions.locationMode == 'history' then Router.HistoryLocation else Router.HashLocation
  )

  Promise.longStackTraces()
  Promise.onPossiblyUnhandledRejection (e) ->
    console.error 'unhandled exception', e, e.stack
    alert(e.message)


  # Show loading page before app is ready
  loading = _.once (Handler) ->
    React.render(React.createElement(Handler, isLoading: true), appOptions.rootNode)

  # registered pollers for previous page
  registeredPollers = Immutable.List()

  # re-render after each route change
  router.run (Handler, state) ->
    # avoid state mutation by router
    state = _.extend {}, state

    RouterActionCreators.routeChangeStart(state)

    # run only once on first render
    loading(Handler)

    # stop pollers required by previous page
    registeredPollers.forEach((action) ->
      Timer.stop(action)
    )

    # async data handling inspired by https://github.com/rackt/react-router/blob/master/examples/async-data/app.js
    promises = RoutesStore
      .getRequireDataFunctionsForRouterState(state.routes)
      .map((requireData) ->
        requireData(state.params)
      ).toArray()

    # wait for data and trigger render
    Promise.all(promises)
    .then(->
      RouterActionCreators.routeChangeSuccess(state)
      React.render(React.createElement(Handler), appOptions.rootNode)

      # Start pollers for new page
      registeredPollers = RoutesStore
        .getPollersForRoutes(state.routes)
        .map((poller) ->
          callback = -> poller.get('action')(state.params)
          Timer.poll(callback, poller.get('interval'))
          return callback
        )

    ).catch((error) ->
      # render error page
      console.log error, error.stack
      RouterActionCreators.routeChangeError(error)
      React.render(React.createElement(Handler, isError: true), appOptions.rootNode)
    )

global.kbcApp =
  start: startApp
  helpers:
    getUrlParameterByName: (name, searchString) ->
      name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
      regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
      results = regex.exec(searchString)
      (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))
    React: React
    Immutable: Immutable

  ###
    Application parts used on non SPA pages
  ###
  parts:
    ProjectSelect: require './react/layout/project-select/ProjectSelect.coffee'
