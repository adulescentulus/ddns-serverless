#!/bin/bash

# MAYBE CHANGE THESE
ip_file="ip.txt"
id_file="cloudflare.ids"
log_file="cloudflare.log"

# LOGGER
log() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" #>> $log_file
    fi
}


update() {
    [[ -z $api_token ]] && echo Please set api_token environment variable && exit 1
    [[ -z $1 ]] && echo Please set zone_name && exit 1 || zone_name=$1
    [[ -z $2 ]] && echo Please set record_name && exit 1 || record_name=$2
    [[ -z $3 ]] && echo Please set ip && exit 1 || ip=$3
    # SCRIPT START
    log "Check Initiated"
    zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "Authorization: Bearer $api_token" -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id' )
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name.$zone_name" -H "Authorization: Bearer $api_token" -H "Content-Type: application/json"  | jq -r '{"result"}[] | .[0] | .id')

    update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "Authorization: Bearer $api_token" -H "Content-Type: application/json" --data "{\"id\":\"$zone_identifier\",\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":60}")

    if [[ $update == *"\"success\":false"* ]]; then
        message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
        log "$message"
        echo -e "$message"
        exit 1 
    else
        message="IP changed to: $ip"
        log "$message"
        echo "$message"
    fi
}