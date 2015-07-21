React = require 'react'
Modal = React.createFactory(require('react-bootstrap').Modal)
ButtonToolbar = React.createFactory(require('react-bootstrap').ButtonToolbar)
Button = React.createFactory(require('react-bootstrap').Button)
Panel = React.createFactory(require('react-bootstrap').Panel)
ConfirmButtons = require '../../../../react/common/ConfirmButtons'
TaskSelectTable = require '../components/TaskSelectTable'

OrchestrationActionCreators = require '../../ActionCreators'

{div, p, strong} = React.DOM

module.exports = React.createClass
  displayName: 'RunOrchestration'
  propTypes:
    orchestration: React.PropTypes.object.isRequired
    tasks: React.PropTypes.object
    onRequestRun: React.PropTypes.func.isRequired

  render: ->
    Modal title: "Run orchestration #{@props.orchestration.get('name')}", onRequestHide: @props.onRequestHide,
      div className: 'modal-body',
        p null,
          'You are about to run the orchestration ',
           strong null, @props.orchestration.get('name'),
           ' manually and the notifications will be sent only to you.'
        if @props.tasks
          Panel
            header: 'Choose orchestration tasks to run'
            collapsible: true
          ,
            React.createElement TaskSelectTable,
              tasks: @props.tasks
              onTaskUpdate: @_handleTaskUpdate
      div className: 'modal-footer',
        React.createElement ConfirmButtons,
          isDisabled: false
          saveLabel: 'Run'
          onCancel: @props.onRequestHide
          onSave: @_handleRun

  _handleRun: ->
    @props.onRequestHide()
    @props.onRequestRun()

  _handleTaskUpdate: ->
    console.log('update')