# frozen_string_literal: true

require 'net/http'
require 'json'

def lambda_handler(event:, context:)
  sns_msg = JSON.parse(event['Records'][0]['Sns']['Message'])

  # ping webhook (slack / mattermost)
  custom_msg = { 'Ping' => '<!here> [@here]' }

  # generate Alarm URL from Alarm ARN
  regex = /arn:aws:cloudwatch:([a-z0-9\-]+):\d+:alarm:(.+)/
  arn = sns_msg['AlarmArn']
  matches = arn.match(regex)

  if matches
    custom_msg['AlarmURL'] = "https://#{matches[1]}.console.aws.amazon.com/cloudwatch/home?region=#{matches[1]}#alarmsV2:alarm/#{matches[2]}"
  end

  # general alarm information
  custom_msg['AlarmName'] = sns_msg['AlarmName']
  custom_msg['Region'] = sns_msg['Region']
  custom_msg['AlarmArn'] = sns_msg['AlarmArn']
  custom_msg['OldStateValue'] = sns_msg['OldStateValue']
  custom_msg['NewStateValue'] = sns_msg['NewStateValue']
  custom_msg['NewStateReason'] = sns_msg['NewStateReason']
  custom_msg['StateChangeTime'] = sns_msg['StateChangeTime']

  message = JSON.pretty_generate(custom_msg, { indent: "\t" })

  logs = { message: message }

  payload = {
    username: ENV.fetch('USERNAME', 'snsbot'),
    text: message,
    icon_emoji: ENV.fetch('EMOJI', ':police_car:')
  }.to_json

  ENV['WEBHOOK_URLS'].split(',').each do |url|
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = payload

    res = http.request(req)
    logs.merge!({ host: uri.host, code: res.code, message: res.message })
  end

  logs
end
