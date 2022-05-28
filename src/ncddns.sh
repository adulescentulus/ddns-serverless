APILIB=cf-ddns.sh

loadLib() {
    # Initialization
    SOURCE_RESPONSE="$(mktemp)"
    source $LAMBDA_TASK_ROOT/$APILIB > $SOURCE_RESPONSE 2>&1
    if [[ $? -eq "0" ]]; then
        rm -f -- "$SOURCE_RESPONSE"
    else
        sendInitError "Failed to source file ${APILIB}. '$(cat $SOURCE_RESPONSE)'" "InvalidHandlerException"
        echo APILIB $APILIB not found
        exit 1
    fi
}

handler () {
    loadLib

    set -e
    # Event Data is sent as the first parameter
    EVENT_DATA=$1

    debug=${VERBOSE}
    if [ $debug = true ]; then
        # This is the Event Data
        echo $EVENT_DATA
    fi
	
    # Example of command usage
    EVENT_JSON=$(echo $EVENT_DATA | jq .)

	EVENT_PATH=$(echo $EVENT_DATA | jq -r '.path')
    DDNS_HOST=$(echo ${EVENT_PATH} | sed -n 's#/[[:alnum:]_-]\+/host/\([0-9A-Za-z]*\.ddns\)\.networkchallenge\.de/id/\([0-9]\+\)/ip/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)#\1#p')
	echo using host $DDNS_HOST
	DDNS_ID=$(echo ${EVENT_PATH} | sed -n 's#/[[:alnum:]_-]\+/host/\([0-9A-Za-z]*\.ddns\)\.networkchallenge\.de/id/\([0-9]\+\)/ip/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)#\2#p')
	echo using host id $DDNS_ID
    
	DDNS_IP=$(echo ${EVENT_PATH} | sed -n 's#/[[:alnum:]_-]\+/host/.*/id/[0-9]\+/ip/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)#\1#p')
	[[ -z $DDNS_IP ]] && exit 1
	update networkchallenge.de $DDNS_HOST $DDNS_IP

    # This is the return value because it's being sent to stderr (>&2)
    echo "{\"statusCode\": 200}" >&2
}