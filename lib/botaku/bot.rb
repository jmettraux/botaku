
module Botaku

  class Bot

    attr_reader :client, :opts

    def initialize(opts)

      fail ArgumentError.new('missing :token') unless opts[:token]

      @opts = opts
    end

    def _self

      @client._self
    end

    def name

      @client.objects[_self['id']]['name']
    end

    def say(*as)

      @client.say(*(as + [ @channel ]))
    end

    def typing(channel=@channel)

      @client.typing(channel: channel)
    end

    def run

      @client = Botaku::Client.new(@opts.dup)

      @client.on('hello') { invoke(:hello) }
      @client.on(:close) { |d| invoke(:close, d) }

      @client.on('message') do |d|
        (invoke_command(d) || invoke(:message, d)) if d['user'] != _self['id']
      end

      @client.run
    end
    alias join run

    private

    def determine_conf_name

      self.class.name.split(':').last.downcase[0..-4]
    end

    def invoke_command(data)

      public_methods.sort.grep(/\Aon_command_[a-z]+\z/)
        .each do |meth|
          m = match_command(data, meth.to_s[11..-1])
          next unless m
          data['match'] = m
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

    def match_command(data, command)

      m = data['text'].match(/\A\s*#{command}(?:\s+(.+))?\z/i)
      m ? (m[1] || '').split : nil
    end

    %w[
      obj obj_id obj_name
      user user_id user_name
      channel channel_id channel_name
    ].each do |m|
      define_method(m) { |o| @client.send(m, o) }
    end
  end
end

