import React from 'react';
import moment from 'moment';
import {Map} from 'immutable';
import {Button, Modal} from 'react-bootstrap';
import {diffJson} from 'diff';
import DetailedDiff from './VersionsDiffModalComponents/DetailedDiff';

const COLOR_ADD = '#cfc';
const COLOR_REMOVE = '#fcc';

const PROPS_TO_COMPARE = ['configuration', 'changeDescription'];
function prepareDiffObject(versionObj) {
  if (!versionObj) return null;
  let result = Map();
  for (let prop of PROPS_TO_COMPARE) {
    result = result.set(prop, versionObj.get(prop));
  }
  return result.toJS();
}

function setSignToString(str, sign) {
  if (str[0] === '') {
    return sign + str.substr(1);
  } else {
    return sign + str;
  }
}

function preparseDiffParts(parts) {
  let previousPart = null;
  let result = [];
  for (let part of parts) {
    const isChanged = part.added || part.removed;
    if (!isChanged) {
      if (previousPart) result.push(previousPart);
      previousPart = null;
      result.push(part);
      // if part is added or removed
    } else if (previousPart) {
      const multiPart = {
        isMulti: true,
        first: previousPart,
        second: part
      };
      previousPart = null;
      result.push(multiPart);
    } else {
      previousPart = part;
    }
  }
  return result;
}

export default React.createClass({

  propTypes: {
    show: React.PropTypes.bool.isRequired,
    onClose: React.PropTypes.func.isRequired,
    referentialVersion: React.PropTypes.object.isRequired,
    compareVersion: React.PropTypes.object.isRequired
  },

  getInitialState() {
    return {
      showChangedOnly: false
    };
  },

  render() {
    return (
      <Modal bsSize="large" show={this.props.show} onHide={this.props.onClose}>
        <Modal.Header closeButton>
          <Modal.Title>Compare</Modal.Title>
          <ul>
            <li>
              <strong>{this.renderVersionInfo(this.props.referentialVersion)}</strong>
            </li>
            <li>
              <strong>{this.renderVersionInfo(this.props.compareVersion)}</strong>
            </li>
          </ul>
        </Modal.Header>
        <Modal.Body>
          {this.renderFilterRow()}
          {this.renderDiff()}
        </Modal.Body>
        <Modal.Footer>
          <Button
            bsStyle="link"
            onClick={this.props.onClose}>
            Close
          </Button>
        </Modal.Footer>
      </Modal>
    );
  },

  renderFilterRow() {
    return (
      <div className="row" style={{'padding-bottom': '8px'}}>
        <div className="col-md-12">
          <div className="checkbox" >
            <label>
              <input
                checked={this.state.showChangedOnly}
                type="checkbox"
                onChange={this.toggleShowChanged}/>
              Show changed parts only
            </label>
          </div>
        </div>
      </div>
    );
  },

  toggleShowChanged(e) {
    const val = e.target.checked;
    this.setState({showChangedOnly: val});
  },


  versionDescription(version) {
    return `#${version.get('version')} (${version.get('changeDescription')}) `;
  },

  renderVersionInfo(version) {
    return (
      <span>
        {this.versionDescription(version)}
        {' '}
        <small>
          {moment(version.get('created')).fromNow()} by {version.getIn(['creatorToken', 'description'], 'unknown')}
        </small>
      </span>
    );
  },

  renderDiff() {
    const dataDiff = this.getDiff();
    const preparsedParts = preparseDiffParts(dataDiff);
    const parts = preparsedParts.map((part) => {
      if (part.isMulti) return this.renderMultiDiff(part.first, part.second);
      return this.renderSimplePreDiff(part);
    });
    return (
      <div>
        {parts}
      </div>
    );
  },

  renderMultiDiff(firstPart, secondPart) {
    const middlePart = (
      <DetailedDiff
        firstPart={firstPart}
        firstPartDescription={this.versionDescription(this.props.referentialVersion)}
        secondPart={secondPart}
        secondPartDescription={this.versionDescription(this.props.compareVersion)}
      />);

    return [
      this.renderSimplePreDiff(firstPart),
      middlePart,
      this.renderSimplePreDiff(secondPart)];
  },

  renderSimplePreDiff(part) {
    let val = part.value;
    let color = '';
    if (part.added)   {
      color = COLOR_ADD;
      val = setSignToString(val, '+');
    }
    if (part.removed) {
      color = COLOR_REMOVE;
      val = setSignToString(val, '-');
    }
    const isChanged = [COLOR_ADD, COLOR_REMOVE].indexOf(color) >= 0;
    if (!isChanged && this.state.showChangedOnly) return null;
    return (
      <pre style={{'margin-bottom': '0px',
                   'border-radius': '0',
                   'border': 'none',
                   'background-color': color}}>
        {val}
      </pre>);
  },

  getDiff() {
    if (!this.props.referentialVersion || !this.props.compareVersion) {
      return [];
    }
    const referenceData = prepareDiffObject(this.props.referentialVersion);
    const compareWithData = prepareDiffObject(this.props.compareVersion);
    return diffJson(compareWithData, referenceData);
  }


});