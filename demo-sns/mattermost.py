#!/usr/bin/python3.9
import urllib3
import json

http = urllib3.PoolManager()


def lambda_handler(event, context):
  url = "https://chat.executionlab.asia/hooks/qwwig7dbrbgouj7coiqmtt7tzw"
  msg = {
    "username": "sns",
    "text": event["Records"][0]["Sns"]["Message"],
    "icon_emoji": ":sos:",
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
