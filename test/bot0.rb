
$: << 'lib'

require 'botaku'

class ZeroBot < Botaku::Bot

  def on_hello

    p [ :on_hello, @client.self.id ]

    say('ZeroBot alive', '#test')
  end

#  def on_close
#
#    p [ :on_close ]
#
#    say('ZeroBot says bye!', '#test')
#  end

  def on_message(data)

    p [ :on_message, user_name(data), data.text ]
  end
end

ZeroBot.new(token: File.read('test/.slack_api_token').strip).join

