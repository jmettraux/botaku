
require 'pp'

$: << 'lib'
require 'botaku'


class ZeroBot < Botaku::Bot

  def on_hello

    p [ :on_hello, _self['id'] ]

    say(
      "I am #{name} (#{self.class}) from #{`uname -a`}...",
      '#test')
  end

#  def on_close
#
#    p [ :on_close ]
#
#    say('ZeroBot says bye!', '#test')
#  end

  def on_message(data)

    typing(data['channel'])
    say("@#{user_name(data)} said: #{data['text'].inspect}", data['channel'])
    #p [ :on_message, user_name(data), data['text'] ]
  end
end

#ZeroBot.new(token: File.read('test/.slack_api_token').strip).run
  # or
ZeroBot.new(token: 'test/.slack_api_token').run

