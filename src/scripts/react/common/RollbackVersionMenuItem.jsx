import React from 'react';
import {MenuItem} from 'react-bootstrap';
import RollbackVersionModal from './RollbackVersionModal';
import {Loader} from 'kbc-react-components';

export default React.createClass({

  propTypes: {
    version: React.PropTypes.object.isRequired,
    onRollback: React.PropTypes.func.isRequired,
    isPending: React.PropTypes.bool
  },

  getInitialState() {
    return {
      showModal: false
    };
  },

  closeModal() {
    this.setState({'showModal': false});
  },

  openModal() {
    this.setState({'showModal': true});
  },

  onRollback() {
    this.props.onRollback();
    this.closeModal();
  },

  render() {
    if (this.props.isPending) {
      return (
        <MenuItem
          eventKey={this.props.version.get('version') + '-rollback'}
          disabled
        >
          <em className="fa fa-fw">
            <Loader/>
          </em>
          Rollback
        </MenuItem>
      );
    } else {
      return (
        <MenuItem
          eventKey={this.props.version.get('version') + '-rollback'}
          onSelect={this.openModal}
        >
          <em className="fa fa-undo fa-fw"> </em>
          Rollback
          <RollbackVersionModal
            version={this.props.version}
            show={this.state.showModal}
            onClose={this.closeModal}
            onRollback={this.onRollback}
          />
        </MenuItem>
      );
    }
  }
});
