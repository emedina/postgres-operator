#! /usr/bin/env bash

# enable unofficial bash strict mode
set -o errexit
set -o nounset
set -o pipefail
IFS=$'\n\t'

ERRORCOUNT=0

function dump {
    # settings are taken from the environment
    PGPASSWORD="$PGPASSWORD" pg_dump -U "$PGUSER" --no-owner -h "$PGHOST"
}

function compress {
    pigz --best
}

set -x
# use $LOGICAL_BACKUP_S3_BUCKET to refer to the network folder to leave this backup.
PATH_TO_BACKUP=$PATH_TO_BACKUP/$(date +%s).sql.gz

dump | compress >"$PATH_TO_BACKUP"
[[ ${PIPESTATUS[0]} != 0 || ${PIPESTATUS[1]} != 0 || ${PIPESTATUS[2]} != 0 ]] && (( ERRORCOUNT += 1 ))
set +x

exit $ERRORCOUNT
