#!/bin/bash
#
# Script to monitor a CouchDB instance's changefeed, and periodically feed the changes into RIAK
#             18/05/2015 - Darren Gibbard
#
#

usage(){
    echo
    echo "Usage: $0 <config_file>"
    exit 1
}

if [ "x$1" = "x" ]; then
    echo "Config File not specified."
    usage
elif [ ! -f "$1" ]; then
    echo "Config file $1 not found."
    usage
else
    CONF=$1
fi


. $CONF

# List out our Essential Config Items for checking:
VARS="\
COUCHDB_HOST:$COUCHDB_HOST \
COUCHDB_DB:$COUCHDB_DB \
COUCHDB_PORT:$COUCHDB_PORT \
COUCHDB_START_SEQ:$COUCHDB_START_SEQ \
MAX_CHANGES:$MAX_CHANGES \
RIAK_HOST:$RIAK_HOST \
RIAK_DB:$RIAK_DB \
COUCHDB_VALIDSSL:$COUCHDB_VALIDSSL \
RIAK_VALIDSSL:$RIAK_VALIDSSL \
SEQ_FILE:$SEQ_FILE \
TMP_FILE:$TMP_FILE \
DELAY:$DELAY \
"

# Check each essential config item to ensure it's set.
for i in $VARS; do
    VARNAME=$(echo $i | awk -F: '{print$1}')
    VARVALUE=$(echo $i | awk -F: '{print$2}')
    if [ "x$VARVALUE" = "x" ]; then
        echo "... ERROR: Configuration Setting \"$VARNAME\" not set."
        usage
    fi
done

# See if we need to manage CouchDB Authentication:
if [ "x${COUCHDB_USER}" = "x" ]&&[ "x${COUCHDB_PASS}" = "x" ]; then
    COUCHDB_AUTH=""
elif [ ! "x${COUCHDB_USER}" = "x" ]&&[ ! "x${COUCHDB_PASS}" = "x" ]; then
    COUCHDB_AUTH="${COUCHDB_USER}:${COUCHDB_PASS}@"
else
    echo '... ERROR: CouchDB Username OR Password specified, but not both/none!'
    usage
fi

# See if we need to manage RIAK Authentication:
if [ "x${RIAK_USER}" = "x" ]&&[ "x${RIAK_PASS}" = "x" ]; then
    RIAK_AUTH=""
elif [ ! "x${RIAK_USER}" = "x" ]&&[ ! "x${RIAK_PASS}" = "x" ]; then
    RIAK_AUTH="${RIAK_USER}:${RIAK_PASS}@"
else
    echo '... ERROR: RIAK Username OR Password specified, but not both/none!'
    usage
fi

# Setup Curl for CouchDB Connections:
if [ $COUCHDB_VALIDSSL = "true" ]; then
    COUCHDB_CURL="curl"
else
    COUCHDB_CURL="curl -k"
fi

# Setup Curl for RIAK Connections:
if [ $RIAK_VALIDSSL = true ]; then
    RIAK_CURL="curl"
else
    RIAK_CURL="curl -k"
fi

# Check to see if CouchDB Sequence file exists; attempt to load in Sequence.
if [ -f "$SEQ_FILE" ]; then
    echo "Loading in Sequence from $SEQ_FILE."
    . $SEQ_FILE
    if [ ! "x$SEQUENCE" = "x" ]; then
        echo "Loaded sequence: $SEQUENCE"
    else
        echo "Failed to load valid sequence number from $SEQ_FILE. Using configuration default sequence start point of $COUCHDB_START_SEQ"
        SEQUENCE=${COUCHDB_START_SEQ}
    fi
else
    echo "... INFO: No Sequence file found. Starting from configuration default sequence start point of ${COUCHDB_START_SEQ}"
    SEQUENCE=${COUCHDB_START_SEQ}
fi

# Main loop
while :; do
    # Curl CouchDB, get list of docs from change feed since $SEQUENCE.
    # Verify curl run
    # Verify curl output is non-error
    # Obtain new Sequence number, but don't overwrite existing until completion of processing.
    # Organise documents for import
    # Import into RIAK
    # Verify curl run
    # Verify curl output is non-error
    # Set new sequence number
    # Write out new sequence number to file
    # Delay for $DELAY seconds
done
