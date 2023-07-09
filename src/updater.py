import json
import logging
import time
import traceback
import re
import CloudFlare
import os
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
def lambda_handler(event, context):
  try:
    cf = CloudFlare.CloudFlare()
    zone_name = 'networkchallenge.de'
    if match := re.search(r'/[a-zA-Z0-9-_]+/host/([a-zA-Z0-9-]+\.ddns)\.networkchallenge\.de/id/([a-zA-Z0-9-]+)/ip/([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})', event["path"]):
        try:
            r = cf.zones.get(params={'name': zone_name})
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            exit('/zones.get %s - %d %s' % (zone_name, e, e))
        except Exception as e:
            exit('/zones.get %s - %s' % (zone_name, e))
        zone_id = r['id']
        # get existing record
        try:
            r = cf.zones.dns_records.get(zone_id, params={'name': match[0]})
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            exit('/zones.dns_records.get %s - %d %s' % (match[0], e, e))
        # DNS records to create
        try:
            r = cf.zones.dns_records.put(zone_id, data={'name':match[0], 'type':'A', 'content':match[2], 'ttl': 60})
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            exit('/zones.dns_records.put %s - %d %s' % (match[0], e, e))
        LOGGER.info('Event structure: %s', match[1])
    return {
        'statusCode': 200,
        'body': ""
    }
  except Exception as e:
    traceback.print_exc()
    response_data = {
        'statusCode': 500,
        'error': str(e)
    }
    return response_data