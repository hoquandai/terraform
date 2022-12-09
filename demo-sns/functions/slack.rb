# frozen_string_literal: true

require 'net/http'
require 'json'

def lambda_handler(event:, context:)
  sns_msg = JSON.parse(event['Records'][0]['Sns']['Message'])

  # message's environment
  custom_msg = { 'Environment' => ENV.fetch('ENVIRONMENT', 'dev') }

  # generate Alarm URL from Alarm ARN
  regex = /arn:aws:cloudwatch:([a-z0-9\-]+):\d+:alarm:(.+)/
  arn = sns_msg['AlarmArn']
  matches = arn&.match(regex)

  if matches
    region = matches[1]
    alarm_name = URI::Parser.new.escape(matches[2].to_s)
    custom_msg['AlarmURL'] = "https://#{region}.console.aws.amazon.com/cloudwatch/home?region=#{region}#alarmsV2:alarm/#{alarm_name}"
  end

  # general alarm information
  custom_msg['AlarmName'] = sns_msg['AlarmName']
  custom_msg['AlarmArn'] = sns_msg['AlarmArn']
  custom_msg['OldStateValue'] = sns_msg['OldStateValue']
  custom_msg['NewStateValue'] = sns_msg['NewStateValue']
  custom_msg['NewStateReason'] = sns_msg['NewStateReason']
  custom_msg['StateChangeTime'] = sns_msg['StateChangeTime']

  slack_key = 'SLACK_WEBHOOK_URL'
  slack_status = send_payload(ENV[slack_key], slack_payload(custom_msg), slack_key)

  mmost_key = 'MATTERMOST_WEBHOOK_URL'
  mmost_status = send_payload(ENV[mmost_key], mattermost_payload(custom_msg), mmost_key)

  logs = {}
  logs.merge!(slack_status)
  logs.merge!(mmost_status)

  puts logs
end

def mattermost_payload(message)
  message['Ping'] = '@here'
  serialize_text_message(message)
end

def slack_payload(message)
  message['Ping'] = '<!here>'
  serialize_text_message(message)
end

def serialize_text_message(message)
  {
    username: ENV.fetch('USERNAME', 'snsbot'),
    text: generate_json_message(message),
    icon_emoji: ENV.fetch('EMOJI', ':police_car:')
  }.to_json
end

def generate_json_message(message)
  JSON.pretty_generate(message, { indent: "\t" })
end

def send_payload(url, payload, key)
  return unless url =~ URI::DEFAULT_PARSER.make_regexp

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = payload
  res = http.request(req)

  { key => { code: res.code, message: res.message } }
end
