
require 'pp'

$: << 'lib'
require 'botaku'

#c = Botaku::Client.new(token: File.read('test/.slack_api_token').strip)
  # or
c = Botaku::Client.new(token: 'test/.slack_api_token')

c.on('hello') do
  p [ :hello ]
  c.say('born to be alive...', '#test')
end
c.on('message') do |data|
  p [ :message, data ]
  if data['text'] == 'ping'
    c.say("pong #{data['uname']}", channel: data['channel'])
  end
end

c.run

