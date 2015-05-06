import React from 'react';

import duration from '../../../../../utils/duration';
import TableLink from '../../../../components/react/components/StorageApiTableLink';

export default React.createClass({
    propTypes: {
        tables: React.PropTypes.object.isRequired
    },

    duration(durationSeconds) {
        return duration(Math.round(durationSeconds));
    },

    rows() {
        return this.props.tables
            .get('tables')
            .map((table) => {
                return (
                    <li key={table.get('id')}>
                        <TableLink tableId={table.get('id')}>
                            {table.get('id')} <span className="text-muted">{this.duration(table.get('durationTotalSeconds'))}</span>
                        </TableLink>
                    </li>
                );
            }).toArray();
    },

    render() {
        return (
            <ul>{this.rows()}</ul>
        );
    }
});