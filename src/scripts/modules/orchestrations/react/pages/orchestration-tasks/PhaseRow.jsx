import React, {PropTypes} from 'react';

export default React.createClass({
  propTypes: {
    phase: PropTypes.object.isRequired,
    toggleHide: PropTypes.func.isRequired
  },

  render() {
    return (
      <tr onClick={this.props.toggleHide}>
        <td colSpan="6" className="kbc-cursor-pointer">
          <div>
            <strong>
              {this.props.phase.get('id')}
            </strong>
          </div>
        </td>
      </tr>
    );
  }

});
