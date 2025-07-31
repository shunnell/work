# Adapted from MIT-licensed code here:
# https://github.com/felipefrizzo/terraform-aws-kinesis-firehose/blob/master/LICENSE
"""
For processing data sent to Kinesis Firehose by CloudWatch logs subscription filter.

CloudWatch Logs sends to Firehose records that look like that:
{
   "messageType":"DATA_MESSAGE",
   "owner":"123456789012",
   "logGroup":"log_group_name",
   "logStream":"log_stream_name",
   "subscriptionFilters":[
      "subscription_filter_name"
   ],
   "logEvents":[
      {
         "id":"34347401063152187823588091447941432395582337638937001984",
         "timestamp":1540190731627,
         "message": "{"method":"GET", "path":"/example/12345", "format":"html", "action":"show", "status":200, "params":{ "user_id":"11111" }, "ip":"192.168.0.0", "@timestamp":"2018-10-22T06:45:31.428Z", "@version":"1", "message":"[200] GET /example/12345 (ExampleController#show)"}"
      },
      ...
   ]
}

Lambda will provide a (compressed or not, depending on Firehose settings) top level data structure that looks like:
{
    "records": [
        {
            "data": <CloudWatch format description above>
        },
        ...
    ]
}
"""
from __future__ import annotations

import logging
from base64 import b64encode, b64decode
from gzip import decompress
from json import loads, dumps
from typing import Tuple
import os
import re
import json


STATUS_OK: str = 'Ok'
DROPPED: str = 'Dropped'
FAILED: str = 'ProcessingFailed'

# opentelemetry log pattern
TIMESTAMP_SEVERITY_PATTERN = re.compile(r"^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z) ([A-Z]!) (.+)$")
ACCOUNT_MAPPING: dict[str, str] = loads(os.environ['CLOUD_CITY_ACCT_MAPPINGS'])

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def try_decode(data):
    # Only attempt JSON parson on strings, return unchanged otherwise.
    if isinstance(data, str):
        try:
            return loads(data), True
        except json.JSONDecodeError:
            return data, False
    elif isinstance(data, bytes):
        try:
            decoded_str = data.decode('utf-8')
            return json.loads(decoded_str), True
        except (UnicodeDecodeError, json.JSONDecodeError):
            return data, False
    return data, False


def process(records) -> list:
    while len(records):  # Destructively iterate to keep memory consumption (and thus lambda runtime and $$) low.
        record_id, payload = parse_record(records.pop())
        logger.info(f'Payload to be transform: {payload}')
        message_type: str = payload.get('messageType', '<unknown>')
        if message_type == 'CONTROL_MESSAGE':
            output_record: dict[str, int | str] = {'recordId': record_id, 'result': DROPPED}
        elif message_type == 'DATA_MESSAGE':
            payload = '\r\n'.join(transform(payload))
            logger.info(f'Payload after transformation: {payload}')
            output_record = {
                'recordId': record_id,
                'result': STATUS_OK,
                # b64encode produces binary, but Firehose/Lambda expect ASCII output, so we text-ify the input,
                # base64 it, then re-textify the base64'd output. No functions in the stdlib jumped out that skip these
                # steps.
                'data':  b64encode(payload.encode('UTF-8')).decode('UTF-8')
            }
        else:
            logger.info(f'Unknown messageType: {message_type}')
            output_record = {'recordId': record_id, 'result': FAILED}
        yield output_record


def parse_record(record: dict) -> Tuple[int, dict]:
    data: str = record.pop('data').strip()
    if not data.startswith("{"): # Handle both compressed and uncompressed data
        data = decompress(b64decode(data))
    return record['recordId'], loads(data)

def transform(payload: dict) -> str:
    sourcetype: str  = os.environ['SOURCE_TYPE']
    owner_id: str = payload['owner']
    # Map the owner ID to account name, fallback to original ID if not found
    owner: str = ACCOUNT_MAPPING.get(owner_id, owner_id)
    # referencing fields provided as part of Cloudwatch Logs subscription filters to aws lambda
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#FirehoseExample
    log_group: str = payload['logGroup']
    log_stream: str = payload['logStream']
    events: list = payload['logEvents']
    while events:
        message = events.pop()['message']
        event, is_json = try_decode(message)

        if is_json:
            # Adding cloudwatch log information within event
            event.update({
                "tenant" : owner,
                "logGroup": log_group,
                "logStream": log_stream
            })
            # Some MultiAccount Application logs containing redundant fields log_processed, and log.
            # Removing Improperly formatted 'log' field and preserving the log_processed field.
            if "log_processed" in event:
                del event["log"]
            # when properly formatted log_processed is not available
            elif "log" in event:
                log_content = event["log"]
                if isinstance(log_content, str):
                    parsed_log, is_plain_json = try_decode(log_content)
                    if is_plain_json:
                        event["log"] = parsed_log
                    elif match:= TIMESTAMP_SEVERITY_PATTERN.match(log_content):
                        timestamp, severity, json_part = match.groups()
                        json_content, is_valid_json = try_decode(json_part)
                        # When MultiAccount Application logs contain timestamp and severity appended in front of JSON.
                        if is_valid_json:
                            event["log"] = {
                                "timestamp": timestamp,
                                "severity": severity,
                                "content": json_content
                            }
        else:
            # When event contains plain text
            event = {
                "log": event,
                "tenant": owner,
                "logGroup": log_group,
                "logStream": log_stream
            }
        # providing sourcetype for splunk http event collector
        hec_event = {
            "sourcetype": sourcetype,
            "event": event
        }
        yield dumps(hec_event)

def lambda_handler(event, context) -> dict:
    logger.info('Start Kinesis Firehose data transformation.')
    output = tuple(process(event['records']))
    logger.info(f'Data after finish transformation: {output}')  # TODO pctformat
    return {'records': output}
