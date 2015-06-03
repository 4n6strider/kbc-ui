React = require 'react'
{span, div, a, p, h2} = React.DOM
createStoreMixin = require '../../../../../../../react/mixins/createStoreMixin'
InstalledComponentsStore = require '../../../../../../components/stores/InstalledComponentsStore'

ConfigWrapper = React.createFactory require '../../components/ConfigWrapper'

module.exports = React.createClass

  displayName: 'GeneeaApp'

  mixins: [createStoreMixin(InstalledComponentsStore)]
  getStateFromStores: ->
    configs: InstalledComponentsStore.getComponent('geneea-topic-detection')

  render: ->
    console.log "rendering geneea index"
    ConfigWrapper
      installedConfigurations: @state.configs
