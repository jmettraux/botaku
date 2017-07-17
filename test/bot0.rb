
require 'pp'

$: << 'lib'
require 'botaku'


class ZeroBot < Botaku::Bot

  def on_hello

    p [ :on_hello, sself['id'] ]

    say('ZeroBot alive', '#test')

    #client.on('user_typing') do |event|
    #  p [ :user_typing, event ]
    #end
  end

#  def on_close
#
#    p [ :on_close ]
#
#    say('ZeroBot says bye!', '#test')
#  end

  def on_message(data)

    typing('#test')
    say("@#{user_name(data)} said: #{data['text'].inspect}", '#test')
    #p [ :on_message, user_name(data), data['text'] ]
  end
end

ZeroBot.new(token: File.read('test/.slack_api_token').strip).run

