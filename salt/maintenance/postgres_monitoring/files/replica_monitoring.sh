#!/usr/bin/env bash
#
# Description:  This script queries a PostgreSQL replica's main server to check that replication is running correctly.
#
# Usage: 14 * * * * postgres /path/to/script
#
# MIT License
#
# Copyright (c) 2024 Dogsbody Technology Ltd. & James McKinney
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -euo pipefail

# MAILTO is set in crontab.
HOST=$(hostname)
if [ -f /usr/bin/mail ]; then
    MAIL_CMD="/usr/bin/mail"
else
    MAIL_CMD="/bin/mail"
fi

PSQL="/usr/bin/psql"
OK_REPLICA_LINES="^pid\|^usesysid\|^backend_start\|^sent_lsn\|^write_lsn\|^flush_lsn\|^replay_lsn\|^client_port\|^write_lag|00:00:0\|^flush_lag|00:00:0\|^replay_lag|00:00:\|^write_lag|$\|^flush_lag|$\|^replay_lag|$\|^-\[RECORD1\]----+"
DIR=/home/sysadmin-tools/postgres_replication

# Get replica status.
REPLICATION_STATUS=$($PSQL -x -c "select * from pg_stat_replication")
echo "${REPLICATION_STATUS// /}" | grep -v "$OK_REPLICA_LINES" > $DIR/replication.current.report

# diff returns exit code 1 if files are different.
CURDIFF=$(diff $DIR/replication.current.report $DIR/replication.production.report || true)

if [ "$CURDIFF" != "" ]; then
    $MAIL_CMD -s "$HOST: Replication Error" "$MAILTO" << EOF
====> A diff between current and production is:

$CURDIFF

====> The current replica check output is:

$REPLICATION_STATUS

EOF
fi
