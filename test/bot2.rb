
require 'pp'

$: << 'lib'
require 'botaku'


class TwoBot < Botaku::Bot

  def on_hello

    p [ self.class, :hello ]
    say("I am #{name} (#{self.class}) from #{`uname -a`}...", '#test')
  end

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

