
require 'slack-ruby-client'

#Slack.configure do |config|
#
#  config.token = File.read(Botaku.etc.slack.token).strip
#
#  config.logger = Logger.new($stdout)
#  config.logger.level = Logger::INFO
#end


module Botaku

  VERSION = '0.9.0'

  class Bot

    attr_reader :client, :opts

    def initialize(opts={})

      @opts = opts

      start! if opts[:start]
    end

    def name

      @client.users[@client.self.id].name
    end

    def say(text, channel=nil)

      @client.message(text: text, channel: determine_channel(channel))
    end

    def typing(channel=nil)

      @client.typing(channel: determine_channel(channel))
    end

    def ping

      @client.ping
    end

    def start!

      @client = Slack::RealTime::Client.new

      @client.on(:hello) { invoke(:hello) }
      @client.on(:close) { |d| invoke(:close, d) }
      @client.on(:closed) { |d| invoke(:closed, d) }

      @client.on(:message) do |d|
        (invoke_command(d) || invoke(:message, d)) if d.user != @client.self.id
      end

      @client.start!
    end

    private

    def determine_conf_name

      self.class.name.split(':').last.downcase[0..-4]
    end

    def invoke_command(data)

      public_methods.sort.grep(/\Aon_command_[a-z]+\z/)
        .each do |meth|
          m = match_command(data, meth.to_s[11..-1])
          next unless m
          data.match = m
          self.send(meth, data)
          return true
        end

      false
    end

    def invoke(type, data=nil)

      public_methods.sort.grep(/\Aon_#{type}/)
        .each do |meth|
          args = method(meth).arity == 1 ? [ data ] : []
          r = self.send(meth, *args)
          return true if r == true
        end

      false
    end

    def determine_channel(c)

      c = c || @channel

      channel =
        (c.is_a?(Hash) && c) ||
        @client.channels[c] ||
        @client.channels.find { |k, v| v['name'] == c } ||
        { 'id' => c }

      channel['id']
    end

    def match_command(data, command)

      m = data.text.match(/\A\s*#{command}(?:\s+(.+))?\z/i)
      m ? (m[1] || '').split : nil
    end
  end
end

