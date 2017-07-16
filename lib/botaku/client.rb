
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

    %w[ api rtm ].each do |mod|

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

      URI.escape(arg_value)
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
  end
end

