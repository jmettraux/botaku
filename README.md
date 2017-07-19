
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


### Botaku::Bot#on_message

Upon receiving a message in a channel it participates to, a bot will consider all its `on_message[...]` methods sorted in alphabetical order and call each of them, until one of them returns `true`.

For example, this bot will invoke `#on_message` then `#on_message_b` and stop since `#on_message_b` returns `true`.

```ruby
require 'botaku'

class OneBot < Botaku::Bot

  def on_message(data)

    say("0 @#{user_name(data)} said: #{data['text'].inspect}", data['channel'])
  end

  def on_message_b(data)

    say("1 @#{user_name(data)} said: #{data['text'].inspect}", data['channel'])

    true # stops calling the on_message_xxx chain
  end

  def on_message_c(data)

    say("1 @#{user_name(data)} said: #{data['text'].inspect}", data['channel'])
  end
end

OneBot.new(token: 'test/.slack_api_token').run
```
(See [test/bot1.rb](test/bot1.rb))

Here is perhaps a better example:

```ruby
require 'botaku'

class TwoBot < Botaku::Bot

  def on_message_cheese(data)

    if data['text'].match(/\bcheese\b/i)
      say(
        "We have some Gruyères or some Vacherin, would you like to order some?",
        data['channel'])
      true # stop looking at #on_message...
    end
  end

  def on_message_wine(data)

    if data['text'].match(/\b(wine|red)\b/i)
      say("Sorry @#{user_name(data)}, we're out of wine", data['channel'])
      true # stop looking at #on_message...
    end
  end
end

TwoBot.new(token: 'test/.slack_api_token').run
```
(See [test/bot2.rb](test/bot2.rb))


## license

MIT, see [LICENSE.txt](LICENSE.txt).

