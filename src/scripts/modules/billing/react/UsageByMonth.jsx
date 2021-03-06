import React from 'react';
import {fromJS, List} from 'immutable';
import moment from 'moment';
import MetricsApi from '../MetricsApi';
import FileSize from '../../../react/common/FileSize';
import ComponentsStore from '../../components/stores/ComponentsStore';
import {Panel, Table} from 'react-bootstrap';
import ComponentName from './../../../react/common/ComponentName';
import ComponentIcon from './../../../react/common/ComponentIcon';
import {componentIoSummary} from './Index';
import Loader from './Loader';

function getDatesForMonthlyUsage() {
  return {
    dateFrom: '2016-10-01',
    dateTo: moment().subtract(1, 'day').format('YYYY-MM-DD')
  };
}

function sortComponentsByStorageIoDesc(first, second) {
  const firstStorageIo = first.get('storage').get('inBytes') + first.get('storage').get('outBytes');
  const secondStorageIo = second.get('storage').get('inBytes') + second.get('storage').get('outBytes');
  if (firstStorageIo > secondStorageIo) {
    return -1;
  } else if (firstStorageIo < secondStorageIo) {
    return 1;
  } else {
    return 0;
  }
}

export default React.createClass({

  getInitialState: function() {
    return {
      metricsData: fromJS([]),
      dates: getDatesForMonthlyUsage(),
      showLoader: true
    };
  },

  componentDidMount: function() {
    this.loadMetricsData()
      .then((response) => {
        this.setState({
          metricsData: fromJS(response).reverse(),
          showLoader: false
        });
      });
  },

  loadMetricsData: function() {
    return MetricsApi.getProjectMetrics(this.state.dates.dateFrom, this.state.dates.dateTo, 'month');
  },

  render() {
    if (this.state.showLoader) {
      return (
        <Loader />
      );
    } else {
      return (
        <div style={{marginBottom: '10em'}}>
          <h3>
            {'Consumed Storage IO from '}
            {moment(this.state.dates.dateFrom).format('MMM D, YYYY')}
            {' to '}
            {moment(this.state.dates.dateTo).format('MMM D, YYYY')}
          </h3>
          {this.state.metricsData.map((item) => {
            if (!item.get('components').isEmpty()) {
              return (
                <Panel collapsible={true} header={this.daySummary(item)} key={item.get('dateFrom') + '-' + item.get('dateTo')}>
                  <Table fill className="table">
                    {List([item.get('components').sort(sortComponentsByStorageIoDesc).map(this.dayComponents)])}
                  </Table>
                </Panel>
              );
            } else {
              return (
                <Panel collapsible={true} header={this.daySummary(item)} key={item.get('dateFrom') + '-' + item.get('dateTo')}>
                  N/A
                </Panel>
              );
            }
          })}
        </div>
      );
    }
  },

  daySummary(data) {
    return (
      <div className="row" style={{paddingBottom: '1em'}}>
        <div className="col-sm-8">
          <strong>{moment(data.get('dateFrom')).format('MMM D, YYYY')}</strong>
          {' - '}
          <strong>{moment(data.get('dateTo')).format('MMM D, YYYY')}</strong>
        </div>
        <div className="col-sm-4">
          <strong>
            <FileSize size={componentIoSummary(data.get('components'), 'storage')}/>
          </strong>
        </div>
      </div>
    );
  },

  renderComponentNameAndIcon(componentSlug) {
    const componentFromStore = ComponentsStore.getComponent(componentSlug);

    if (componentFromStore) {
      return (
        <span>
          <ComponentIcon component={componentFromStore} />
          <ComponentName component={componentFromStore} />
        </span>
      );
    } else if (componentSlug === 'storage-direct') {
      return (
        <span>
          <span className="kb-sapi-component-icon kbc-icon-storage" style={{fontSize: '32px', verticalAlign: 'middle'}}/>
          <span>Direct Storage API access</span>
        </span>
      );
    } else {
      return (
        <span>
          <span>{componentSlug}</span>
        </span>
      );
    }
  },

  dayComponents(component) {
    return (
      <tr>
        <td>
          <div className="row">
            <div className="col-md-8">
              {this.renderComponentNameAndIcon(component.get('name'))}
            </div>
            <div className="col-md-4">
              <span style={{lineHeight: '2em'}}>
                <FileSize size={
                  component.get('storage').get('inBytes') + component.get('storage').get('outBytes')
                }/>
              </span>
            </div>
          </div>
        </td>
      </tr>
    );
  }
});
