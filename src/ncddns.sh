APILIB=ncdapi.sh

loadLib() {
    # Initialization
    set +e
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
	DDNSHOST=$(echo ${EVENT_PATH} | sed -n 's#/host/\([0-9A-Za-z]*\.ddns\)\.networkchallenge\.de/ip/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)#\1#p')
	echo using host $DDNSHOST
    if [ $debug = true ]; then
	    getRecords "networkchallenge.de" | jq -r --arg DDNSHOST "$DDNSHOST" '.[] | select(.hostname==$DDNSHOST) | .id'
	fi
    DDNSID=$(getRecords "networkchallenge.de" | jq -r --arg DDNSHOST "$DDNSHOST" '.[] | select(.hostname==$DDNSHOST) | .id')

	echo using id $DDNSID
	[[ -z $DDNSID ]] && exit 1
	DDNSIP=$(echo ${EVENT_PATH} | sed -n 's#/host/.*/ip/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)#\1#p')
	[[ -z $DDNSIP ]] && exit 1
	modRecord $DDNSID $DDNSHOST networkchallenge.de A $DDNSIP

    # This is the return value because it's being sent to stderr (>&2)
    echo "{\"statusCode\": 200}" >&2
}