
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
    end

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
        r = @client.get(@name, meth, args.first)
        JSON.parse(r.body)
      end
      undef :test
    end

    %w[ api rtm ].each do |mod|

      define_method mod do
        @modules[mod] ||= SlackModule.new(self, mod)
      end
    end

    def run

      EM.run do
        @rtm = rtm.start
        ws = Faye::WebSocket::Client.new(@rtm['url'])
        ws.on(:open) { |event| p [ :open, event ] }
        ws.on(:message) { |event| p [ :message, event.data ] }
        ws.on(:close) { |event| p [ :close, event ] }
        ws.on(:error) { |event| p [ :error, event ] }
        p ws.version
        p ws.protocol
      end
    end

#    def join
#
#      @em_thread.join
#    end

    private

    def escape(arg_value)

      URI.escape(arg_value)
    end
  end
end

#r = Botaku::Client
#  .new(token: File.read('.slack_api_token').strip)
#  .rtm.start
#  #.api.test
#pp r['url']

r = Botaku::Client
  .new(token: File.read('.slack_api_token').strip)
  .run

