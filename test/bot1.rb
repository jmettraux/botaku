
require 'pp'

$: << 'lib'
require 'botaku'


class OneBot < Botaku::Bot

  def on_hello

    p [ self.class, :hello ]

    say("I am #{name} (#{self.class}) from #{`uname -a`}...", '#test')
  end

  def on_message(data)

    say("0 #{data['uname']} said: #{data['text'].inspect}", data['channel'])
  end

  def on_message_b(data)

    say("1 #{data['uname']} said: #{data['text'].inspect}", data['channel'])

    true # stops calling the on_message_xxx chain
  end

  def on_message_c(data)

    say("1 #{data['uname']} said: #{data['text'].inspect}", data['channel'])
  end
end

OneBot.new(token: 'test/.slack_api_token').run

