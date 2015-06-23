React = require 'react'
InstalledComponentsActionCreators = require '../../InstalledComponentsActionCreators'

ModalTrigger = React.createFactory(require('react-bootstrap').ModalTrigger)
Modal = React.createFactory(require('react-bootstrap').Modal)
Button = React.createFactory(require('react-bootstrap').Button)
ButtonToolbar = React.createFactory(require('react-bootstrap').ButtonToolbar)
Loader = React.createFactory(require('kbc-react-components').Loader)
RoutesStore = require '../../../../stores/RoutesStore'

{a, i, div, button} = React.DOM

RunModal = React.createFactory React.createClass

  _handleRun: ->
    @props.onRequestHide()
    @props.onRequestRun()

  render: ->
    Modal
      title: @props.title
      onRequestHide: @props.onRequestHide
    ,
      div className: 'modal-body',
        @props.body
      div className: 'modal-footer',
        ButtonToolbar null,
          Button
            bsStyle: 'link'
            onClick: @props.onRequestHide
          ,
            'Close'
          Button
            bsStyle: 'primary'
            onClick: @_handleRun
          ,
            'Run'

module.exports = React.createClass
  displayName: 'RunExtraction'
  propTypes:
    title: React.PropTypes.string.isRequired
    mode: React.PropTypes.oneOf ['button', 'link']
    component: React.PropTypes.string.isRequired
    runParams: React.PropTypes.func.isRequired
    method: React.PropTypes.string.isRequired
    icon: React.PropTypes.string.isRequired
    label: React.PropTypes.string
    redirect: React.PropTypes.bool

  getDefaultProps: ->
    mode: 'button'
    method: 'run'
    icon: 'fa-play'
    redirect: false

  getInitialState: ->
    isLoading: false

  _handleRunStart: ->
    @setState
      isLoading: true

    params =
      method: @props.method
      component: @props.component
      data: @props.runParams()
      notify: !@props.redirect

    InstalledComponentsActionCreators
    .runComponent params
    .then @_handleStarted
    .catch =>
      @setState
        isLoading: false

  _handleStarted: (response) ->
    if @isMounted()
      @setState
        isLoading: false
    if @props.redirect
      RoutesStore.getRouter().transitionTo("jobDetail", {jobId: response.id})

  render: ->
    ModalTrigger
      modal: RunModal
        title: @props.title
        body: @props.children
        onRequestRun: @_handleRunStart
    ,
      if @props.mode == 'button'
        @_renderButton()
      else
        @_renderLink()

  _renderButton: ->
    button
      className: 'btn btn-link'
      onClick: (e) ->
        e.stopPropagation()
        e.preventDefault()
    ,
      @_renderIcon()
      if @props.label
        ' ' + @props.label

  _renderLink: ->
    a
      onClick: (e) ->
        e.stopPropagation()
        e.preventDefault()
    ,
      @_renderIcon()
      ' ' + @props.title

  _renderIcon: ->
    if @state.isLoading
      Loader className: 'fa-fw'
    else
      i className: "fa fa-fw #{@props.icon}"
