
# botaku

A Slack bot abstraction, built on top of [faye-websocket](https://github.com/faye/faye-websocket-ruby) and [httpclient](https://github.com/nahi/httpclient).


## use

Botaku provides `Botaku::Client` and `Botaku::Bot`.

## Botaku::Client

```ruby
require 'botaku'

#c = Botaku::Client.new(token: 'xxxx-111111111111-aaaaaaaaaaaaaaaaaaaaaaaa')
  # or
c = Botaku::Client.new(token: '.slack_api_token')

c.on('hello') do
  p [ :hello ]
  c.say('born to be alive...', '#test')
end
c.on('message') do |data|
  p [ :message, data ]
  c.say('pong', channel: data['channel']) if data['text'].match(/\A\s*ping\b/)
end
```
(See [test/client0.rb](test/client0.rb))

## Botaku::Bot

```ruby
require 'botaku'

class ZeroBot < Botaku::Bot

  def on_hello

    p [ :on_hello, _self['id'] ]

    say(
      "I am #{name} (#{self.class}) from #{`uname -a`}...",
      '#test')
  end

  def on_message(data)

    typing(data['channel'])
    say("@#{user_name(data)} said: #{data['text'].inspect}", data['channel'])
  end
end

#ZeroBot.new(token: 'xxxx-111111111111-aaaaaaaaaaaaaaaaaaaaaaaa')
  # or
ZeroBot.new(token: 'test/.slack_api_token').run
```
(See [test/bot0.rb](test/bot0.rb))


## license

MIT, see [LICENSE.txt](LICENSE.txt).

