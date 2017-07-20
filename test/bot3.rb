
$: << 'lib'
require 'botaku'


class ThreeBot < Botaku::Bot

  def on_hello

    p [ self.class, :hello ]
    say("I am #{name} (#{self.class}) from #{`uname -a`}...", '#test')
  end

  def on_command_weather(data)

    say("it's fine today", data['channel'])
  end

  def on_command_args(data)

    say(data['match'].inspect, data['channel'])
  end

  def on_command_echo(data)

    say(data['line'], data['channel'])
  end
end

ThreeBot.new(token: 'test/.slack_api_token').run

