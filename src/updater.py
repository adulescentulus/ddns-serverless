import json
import logging
import time
import traceback
import re
import CloudFlare
import os
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def update_cf(host, ip):
  cf = CloudFlare.CloudFlare()
  zone_name = 'networkchallenge.de'
  try:
      r = cf.zones.get(params={'name': zone_name})
  except CloudFlare.exceptions.CloudFlareAPIError as e:
      exit('/zones.get %s - %d %s' % (zone_name, e, e))
  except Exception as e:
      exit('/zones.get %s - %s' % (zone_name, e))
  if len(r) == 0:
    exit('/zones.get - %s - no zone found' % (zone_name))
  zone_id = r[0]['id']
  # get existing record
  try:
      r = cf.zones.dns_records.get(zone_id, params={'name': host + "." + zone_name})
  except CloudFlare.exceptions.CloudFlareAPIError as e:
      exit('/zones.dns_records.get %s - %d %s' % (host, e, e))
  LOGGER.info('Event structure: %s', r)
  if len(r) == 0:
    exit('/zones.dns_records.get - %s - no record found' % (host))
  # DNS records to create
  try:
      r = cf.zones.dns_records.put(zone_id, r[0]['id'], data={'name':host, 'type':'A', 'content':ip, 'ttl': 60})
  except CloudFlare.exceptions.CloudFlareAPIError as e:
      exit('/zones.dns_records.put %s - %d %s' % (host + " " + ip, e, e))
  LOGGER.info('Event structure: %s', host)
  return {
      'statusCode': 200,
      'body': ""
  }
def lambda_handler(event, context):
  try:
    if match := re.search(r'/[a-zA-Z0-9-_]+/host/([a-zA-Z0-9-]+\.ddns)\.networkchallenge\.de/id/([a-zA-Z0-9-]+)/ip/([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})', event["path"]):
        return update_cf(match[1],match[3])
    elif match := re.search(r'/[a-zA-Z0-9-_]+/host/([a-zA-Z0-9-]+\.ddns)\.networkchallenge\.de/id/([a-zA-Z0-9-]+)/manual', event["path"]):
        return update_cf(match[1], event['requestContext']['identity']['sourceIp'])
    else:
      return {
      'statusCode': 500,
      'body': "path did not match"
      }
  except Exception as e:
    traceback.print_exc()
    response_data = {
        'statusCode': 500,
        'error': str(e)
    }
    return response_data