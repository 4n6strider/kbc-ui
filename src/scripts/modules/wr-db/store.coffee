Dispatcher = require('../../Dispatcher')
{Map, fromJS, List} = require 'immutable'

StoreUtils = require('../../utils/StoreUtils')
constants = require './constants'


_store = Map
  credentials: Map() #driver#configId
  tables: Map() #driver#configId
  tablesConfig: Map() #driver#configId#tableId
  updatingTables: Map() #driver#configId#tableId
  editing: Map() #driver#configId whatever
  updatingColumns: Map() #driver#configId#tableId
  savingCredentials: Map() #driver#configId
  provisioningCredentials: Map() #driver#configId
  loadingProvCredentials: Map() #driver#configId



WrDbStore = StoreUtils.createStore

  isLoadingProvCredentials: (driver, configId) ->
    _store.hasIn ['loadingProvCredentials', driver, configId]

  getProvisioningCredentials: (driver, configId) ->
    _store.getIn ['provisioningCredentials', driver, configId]

  hasConfiguration: (driver, configId) ->
    @hasTables(driver, configId)

  getSavingCredentials: (driver, configId) ->
    _store.getIn ['savingCredentials', driver, configId]

  hasTables: (driver, configId) ->
    _store.hasIn ['tables', driver, configId]

  getTables: (driver, configId) ->
    _store.getIn ['tables', driver, configId]

  hasCredentials: (driver, configId) ->
    _store.hasIn ['credentials', driver, configId]

  getCredentials: (driver, configId) ->
    _store.getIn ['credentials', driver, configId]

  isUpdatingTable: (driver, configId, tableId) ->
    _store.hasIn ['updatingTables', driver, configId, tableId]

  getUpdatingTables: (driver, configId) ->
    _store.getIn ['updatingTables', driver, configId], Map()

  hasTableConfig: (driver, configId, tableId) ->
    _store.hasIn ['tablesConfig', driver, configId, tableId]

  getTableConfig: (driver, configId, tableId) ->
    _store.getIn ['tablesConfig', driver, configId, tableId]

  getEditingByPath: (driver, configId, path) ->
    editPath = ['editing', driver, configId].concat(path)
    _store.getIn editPath

  getEditing: (driver, configId) ->
    _store.getIn(['editing', driver, configId], Map())

  getUpdatingColumns: (driver, configId, tableId) ->
    _store.getIn(['updatingColumns', driver, configId, tableId])

Dispatcher.register (payload) ->
  action = payload.action
  switch action.type
    when constants.ActionTypes.WR_DB_LOAD_PROVISIONING_START
      driver = action.driver
      configId = action.configId
      _store = _store.setIn ['loadingProvCredentials', driver, configId], true
      WrDbStore.emitChange()
    when constants.ActionTypes.WR_DB_LOAD_PROVISIONING_SUCCESS
      driver = action.driver
      configId = action.configId
      credentials = fromJS action.credentials
      _store = _store.deleteIn ['loadingProvCredentials', driver, configId]
      _store = _store.setIn ['provisioningCredentials', driver, configId], credentials
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SAVE_CREDENTIALS_START
      driver = action.driver
      configId = action.configId
      credentials = action.credentials
      _store = _store.setIn ['savingCredentials', driver, configId], credentials
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SAVE_CREDENTIALS_SUCCESS
      driver = action.driver
      configId = action.configId
      credentials = action.credentials
      _store = _store.deleteIn ['savingCredentials', driver, configId]
      _store = _store.setIn ['credentials', driver, configId], fromJS(credentials)
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SAVE_COLUMNS_START
      driver = action.driver
      configId = action.configId
      tableId = action.tableId
      columns = action.columns
      _store = _store.setIn ['updatingColumns', driver, configId, tableId], columns
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SAVE_COLUMNS_SUCCESS
      driver = action.driver
      configId = action.configId
      tableId = action.tableId
      columns = action.columns
      _store = _store.deleteIn ['updatingColumns', driver, configId, tableId]
      _store = _store.setIn ['tablesConfig', driver, configId, tableId, 'columns'], columns
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SET_EDITING
      driver = action.driver
      configId = action.configId
      path = action.path
      data = action.data
      editPath = ['editing', driver, configId].concat(path)
      _store = _store.setIn editPath, data
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_GET_TABLE_SUCCESS
      driver = action.driver
      configId = action.configId
      tableId = action.tableId
      tableConfig = action.tableConfig
      _store = _store.setIn ['tablesConfig', driver, configId, tableId], fromJS(tableConfig)
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SET_TABLE_START
      driver = action.driver
      configId = action.configId
      tableId = action.tableId
      _store = _store.setIn ['updatingTables', driver, configId, tableId], true
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_SET_TABLE_SUCCESS
      driver = action.driver
      configId = action.configId
      tableId = action.tableId
      dbName = action.dbName
      isExported = action.isExported
      _store = _store.deleteIn ['updatingTables', driver, configId, tableId]

      tables = WrDbStore.getTables(driver, configId)
      table = tables.find (table) ->
        table.get('id') == tableId
      if not table
        table = fromJS
          id: tableId
          name: dbName
          export: isExported
      else
        table = table.set('name', dbName)
        table = table.set('export', isExported)
      tables = tables.map (t) ->
        if t.get('id') == tableId
          return t = table
        return t
      _store = _store.setIn ['tables', driver, configId], tables
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_GET_CONFIGURATION_SUCCESS
      driver = action.driver
      configId = action.configId
      credentials = action.config.credentials
      tables = action.config.tables
      _store = _store.setIn ['tables',      driver, configId], fromJS(tables)
      _store = _store.setIn ['credentials', driver, configId], fromJS(credentials)
      WrDbStore.emitChange()

    when constants.ActionTypes.WR_DB_API_ERROR
      driver = action.driver
      configId = action.configId
      path = action.errorPath
      if path
        _store = _store.deleteIn path
      WrDbStore.emitChange()


module.exports = WrDbStore