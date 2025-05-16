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

STATUS_OK: str = 'Ok'
DROPPED: str = 'Dropped'
FAILED: str = 'ProcessingFailed'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def process(records) -> list:
    while len(records):  # Destructively iterate to keep memory consumption (and thus lambda runtime and $$) low.
        record_id, payload = parse_record(records.pop())
        logger.info(f'Payload to be transform: {payload}')
        message_type: str = payload.get('messageType', '<unknown>')
        if message_type == 'CONTROL_MESSAGE':
            output_record = {'recordId': record_id, 'result': DROPPED}
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
    events: list = payload['logEvents']
    while events:
        message = events.pop()['message']
        event = loads(message)
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
