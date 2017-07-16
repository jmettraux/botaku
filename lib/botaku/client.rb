
require 'json'
require 'httpclient'
require 'faye/websocket'
require 'eventmachine'


module Botaku

  class Client

    def initialize(opts)

      fail ArgumentError.new('missing :token') unless opts[:token]

      @opts = opts

      @base_uri = 'https://slack.com/api'
      @modules = {}
      @http_client = HTTPClient.new
      @rtm = nil
      @handlers = {}
    end

    def sself

      @rtm['self']
    end

    %w[ api chat rtm ].each do |mod|

      define_method mod do
        @modules[mod] ||= SlackModule.new(self, mod)
      end
    end

    def on(type, &block)

      (@handlers[type] ||= []) << block
    end

    def run

      EM.run do
        @rtm = rtm.start
        ws = Faye::WebSocket::Client.new(@rtm['url'])
        [ :open, :error, :close ].each do |event_type|
          ws.on(event_type) { |event| dispatch(event_type, event) }
        end
        ws.on(:message) { |event| dispatch_message(event) }
      end
    end
    alias join run

    # say('hello')
    # say('hello', '#test_channel')
    # say('hello', channel: 'C12345ABC')
    # say('hello', channel: '#test_channel')
    #
    def say(*as)

      args = rework_args(as)
      args[:as_user] = true unless args.has_key?(:as_user)

      chat.postMessage(args)
    end

    def objects

      @objects ||=
        (@rtm['channels'] + @rtm['groups'] + @rtm['users'])
          .inject({}) { |h, o| h[o['id']] = o; h }
    end

    private

    def get(mod, meth, args)

      uri = "#{@base_uri}/#{mod}.#{meth}?token=#{@opts[:token]}"

      args.each do |k, v|
        uri = "#{uri}&#{k}=#{escape(v)}"
      end

      @http_client.get(uri)
    end

    class SlackModule
      def initialize(client, name)
        @client = client
        @name = name
      end
      def method_missing(meth, *args)
        args = [ {} ] if args.empty?
        return super if args.size != 1 || ! args[0].is_a?(Hash)
        r = @client.send(:get, @name, meth, args.first)
        JSON.parse(r.body)
      end
      undef :test
    end

    def escape(arg_value)

      v = arg_value.is_a?(String) ? arg_value : arg_value.inspect

      URI.escape(v)
    end

    def dispatch(event_type, event)

      (@handlers[event_type] || []).each do |block|
        block.arity == 1 ? block.call(event) : block.call
      end
    end

    def dispatch_message(event)

      data = JSON.parse(event.data)

      (@handlers[data['type']] || []).each do |block|
        block.arity == 1 ? block.call(data) : block.call
      end
    end

    def rework_args(as)

      args = {}
      as.each do |a|
        case a
        when Hash then args.merge!(a)
        when /\A#[a-z_]+\z/ then args[:channel] = a
        when String then args[:text] = a
        end
      end

      c = args[:channel]
      args[:channel] = channel_id(c)

      args
    end

    def channel(c)

      case c
      when Hash then c
      when /\A#/ then @rtm['channels'].find { |h| h['name'] == c[1..-1] }
      when /\A[CG][0-9A-Z]+\z/ then @rtm['channels'].find { |h| h['id'] == c }
      else @rtm.find { |h| h['name'] == c }
      end
    end

    def channel_id(c)

      c = channel(c); c ? c['id'] : nil
    end
  end
end

