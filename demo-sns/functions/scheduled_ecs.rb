# frozen_string_literal: true

require 'net/http'
require 'json'

def lambda_handler(event:, context:)
  sns_msg = event['Records'][0]['Sns']['Message']

  custom_msg = {
    'Environment' => ENV.fetch('ENVIRONMENT', 'dev'),
    'Message' => sns_msg
  }

  slack_key = 'SLACK_WEBHOOK_URL'
  slack_status = send_payload(ENV[slack_key], slack_payload(custom_msg), slack_key)

  logs = {}
  logs.merge!(slack_status)

  puts logs
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
  return {} unless url =~ URI::DEFAULT_PARSER.make_regexp

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = payload
  res = http.request(req)

  { key => { code: res.code, message: res.message } }
end
