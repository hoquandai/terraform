#!/usr/bin/python3.9
import urllib3
import json
import os

http = urllib3.PoolManager()


def lambda_handler(event, context):
  url = os.getenv('WEBHOOK_URL')
  msg = {
    "username": os.getenv('USERNAME'),
    "text": event["Records"][0]["Sns"]["Message"],
    "icon_emoji": os.getenv('EMOJI'),
  }

  encoded_msg = json.dumps(msg).encode("utf-8")
  resp = http.request("POST", url, body=encoded_msg)
  print(
    {
      "message": event["Records"][0]["Sns"]["Message"],
      "status_code": resp.status,
      "response": resp.data,
    }
  )
