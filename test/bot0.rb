
require 'pp'

$: << 'lib'
require 'botaku'


class ZeroBot < Botaku::Bot

  def on_hello

    p [ :on_hello, sself['id'] ]

    say('ZeroBot alive', '#test')
  end

#  def on_close
#
#    p [ :on_close ]
#
#    say('ZeroBot says bye!', '#test')
#  end

  def on_message(data)

    typing('#test')
    p [ :on_message, user_name(data), data['text'] ]
    sleep 10
    say("@#{user_name(data)} said: #{data['text'].inspect}", '#test')
  end
end

ZeroBot.new(token: File.read('test/.slack_api_token').strip).run

