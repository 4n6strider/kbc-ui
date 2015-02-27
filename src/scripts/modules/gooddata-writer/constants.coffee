keyMirror = require('react/lib/keyMirror')

module.exports =

  ActionTypes: keyMirror
    GOOD_DATA_WRITER_LOAD_START: null
    GOOD_DATA_WRITER_LOAD_SUCCESS: null
    GOOD_DATA_WRITER_LOAD_ERROR: null

    GOOD_DATA_WRITER_LOAD_TABLE_START: null
    GOOD_DATA_WRITER_LOAD_TABLE_SUCCESS: null
    GOOD_DATA_WRITER_LOAD_TABLE_ERROR: null

    GOOD_DATA_WRITER_TABLE_EXPORT_STATUS_CHANGE_START: null
    GOOD_DATA_WRITER_TABLE_EXPORT_STATUS_CHANGE_SUCCESS: null
    GOOD_DATA_WRITER_TABLE_EXPORT_STATUS_CHANGE_ERROR: null

    GOOD_DATA_WRITER_COLUMNS_EDIT_START: null
    GOOD_DATA_WRITER_COLUMNS_EDIT_CANCEL: null
    GOOD_DATA_WRITER_COLUMNS_EDIT_UPDATE: null


  ColumnTypes: keyMirror
    ATTRIBUTE: null
    CONNECTION_POINT: null
    DATE: null
    FACT: null
    HYPERLINK: null
    IGNORE: null
    LABEL: null
    REFERENCE: null

  DataTypes: keyMirror
    BIGINT: null
    DATE: null
    DECIMAL: null
    INT: null
    VARCHAR: null

  SortOrderOptions: keyMirror
    ASC: null
    DESC: null