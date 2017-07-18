
# botaku

A Slack bot abstraction, built on top of [faye-websocket](https://github.com/faye/faye-websocket-ruby) and [httpclient](https://github.com/nahi/httpclient).


## use

Botaku provides `Botaku::Client` and `Botaku::Bot`.

## Botaku::Client

```ruby
require 'botaku'
c = Botaku::Client.new(token: '.slack_api_token')

c.on('hello') do
  p [ :hello ]
  c.say('born to be alive...', '#test')
end
c.on('message') do |data|
  p [ :message, data ]
  c.say('pong', channel: data['channel'] if data['text'].match(/\A\s*ping\b/)
end
```

## Botaku::Bot

TODO


## license

MIT, see [LICENSE.txt](LICENSE.txt).

