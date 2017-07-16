
#r = Botaku::Client
#  .new(token: File.read('.slack_api_token').strip)
#  .rtm.start
#  #.api.test
#pp r['url']

$: << 'lib'
require 'botaku'

c = Botaku::Client.new(token: File.read('test/.slack_api_token').strip)

c.on('hello') do
  p [ :hello ]
  #c.say('born to be alive...', '#test')
end
c.on('message') do |data|
  p [ :message, data ]
  if data['text'] == 'ping'
    c.say('pong', channel: data['channel'])
  end
end

c.run

