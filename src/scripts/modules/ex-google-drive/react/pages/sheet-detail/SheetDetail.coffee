React = require('react')
ExGdriveStore = require '../../../exGdriveStore.coffee'
createStoreMixin = require '../../../../../react/mixins/createStoreMixin.coffee'
RoutesStore = require '../../../../../stores/RoutesStore.coffee'
Input = React.createFactory(require('react-bootstrap').Input)


{div, span, form } = React.DOM
module.exports = React.createClass
  displayName: "SheetDetail"
  mixins: [createStoreMixin(ExGdriveStore)]

  getStateFromStores: ->
    sheetId = RoutesStore.getCurrentRouteParam('sheetId')
    config = RoutesStore.getCurrentRouteParam('config')
    sheet = ExGdriveStore.getConfigSheet(config,sheetId)
    if ExGdriveStore.isEditingSheet(config, sheetId)
      sheet = ExGdriveStore.getEditingSheet(config, sheetId)
    sheet: sheet

  render: ->
    #console.log @state.sheet.toJS()
    div {className: 'container-fluid'},
      form className: 'form-horizontal',
        div className: 'row',
          @_createInput 'Document Title', 'title', 'static'
          @_createInput 'Sheet Title', 'sheetTitle', 'static'
          @_createInput 'Document GoogleId', 'googleId', 'static'
          @_createInput 'Sheet Id', 'sheetId', 'static'

  _handleChange: (propName, event) ->



  _createInput: (labelValue, propName, type = 'text') ->
    Input
      label: labelValue
      type: type
      value: @state.sheet.get propName
      labelClassName: 'col-xs-4'
      wrapperClassName: 'col-xs-8'
      onChange: @_handleChange.bind @, propName
