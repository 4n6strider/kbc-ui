import React, {PropTypes} from 'react';
import {fromJS} from 'immutable';
import KeygenApi from '../../../../components/KeygenApi';
import {Check} from 'kbc-react-components';
import {Input, FormControls} from 'react-bootstrap';
import {Protected} from 'kbc-react-components';
import Clipboard from '../../../../../react/common/Clipboard';
import {Loader} from 'kbc-react-components';
const StaticText = FormControls.Static;


export default React.createClass({
  propTypes: {
    onChange: PropTypes.func,
    data: PropTypes.object,
    isEditing: PropTypes.bool
  },

  getInitialState() {
    return {isGenerating: false};
  },

  render() {
    return (
      <div className="row">
        {this.renderEnableCheckbox()}
        {this.isEnabled() ?
         <span>
           {this.createInput('SSH host', 'sshHost', 'text', false)}
           {this.createInput('SSH user', 'user', 'text', false)}
           {this.createInput('SSH port', 'sshPort', 'number', false)}
           {this.renderPublicKey()}
         </span>
         : null
        }
      </div>
    );
  },

  isEnabled() {
    return this.props.data.get('enabled');
  },

  renderEnableCheckbox() {
    if (this.props.isEditing) {
      return (
        <Input
          disabled={!this.props.isEditing}
          type="checkbox"
          label={<span>Enable SSH Tunnel {this.renderHelp()}</span>}
          wrapperClassName="col-xs-8"
          checked={this.isEnabled()}
          onChange={() => this.props.onChange(this.props.data.set('enabled', !this.isEnabled()))}
        />
      );
    } else {
      return (
        <StaticText
          label={<span>SSH Tunnel {this.renderHelp()}</span>}
          labelClassName="col-xs-4"
          wrapperClassName="col-xs-8">
          <Check isChecked={this.isEnabled()} />
        </StaticText>
      );
    }
  },

  renderHelp() {
    return (
      <small>
        <a href="https://developers.keboola.com/integrate/database/" target="_blank">
          Help
          <i className="fa fa-question-circle fa-fw"/>
        </a>
      </small>
    );
  },

  renderPublicKey() {
    const publicKey = this.props.data.getIn(['keys', 'public']);
    return (
      <div className="form-group">
        <label className="control-label col-sm-4">
          SSH Public Key
        </label>
        <div className="col-sm-8">
          {(publicKey ?
            <pre>
              {publicKey}
              {this.renderClipboard(publicKey)}
            </pre> : null
           )}
            {(this.props.isEditing ? this.renderKeyGen(publicKey) : null)}
        </div>
      </div>
    );
  },

  renderKeyGen(publicKey) {
    return (
      <span>
        <button
          type="button"
          disabled={this.state.isGenerating}
          onClick={this.generateKeys}
          style={{'padding-left': 0}}
          className="btn btn-link">
          {publicKey ? 'Regenerate' : 'Generate'}
        </button>
        {this.state.isGenerating ? <Loader /> : null}
      </span>
    );
  },

  generateKeys() {
    this.setState({isGenerating: true});
    KeygenApi.generateKeys().then((keys) => {
      const newKeys = {
        'public': keys.public,
        '#private': keys.private
      };
      this.props.onChange(this.props.data.setIn(['keys'], fromJS(newKeys)));
      this.setState({
        isGenerating: false
      });
    });
  },

  handleChange(propName, event) {
    const value = event.target.value;
    this.props.onChange(this.props.data.setIn([].concat(propName), value));
  },

  createInput(labelValue, propName, type = 'text', isProtected = false) {
    const value = this.props.data.get(propName);
    if (this.props.isEditing) {
      return (
        <Input
          label={labelValue}
          type={type}
          value={this.props.data.get(propName)}
          labelClassName="col-xs-4"
          wrapperClassName="col-xs-8"
          onChange={this.handleChange.bind(this, propName)} />);
    } else if (isProtected) {
      return (
        <StaticText
          label={labelValue}
          labelClassName="col-xs-4"
          wrapperClassName="col-xs-8">
          <Protected>
            {this.props.data.get(propName)}
          </Protected>
          {this.renderClipboard(value)}
        </StaticText>);
    } else {
      return (
        <StaticText
          label={labelValue}
          labelClassName="col-xs-4"
          wrapperClassName="col-xs-8">
          {this.props.data.get(propName)}
          {this.renderClipboard(value)}
        </StaticText>);
    }
  },

  renderClipboard(value) {
    if (value) {
      return (<Clipboard text={value} />);
    } else {
      return null;
    }
  }
});
