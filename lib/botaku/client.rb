
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
      @ws_client = nil
      @rtm = nil
      @handlers = {}

      @http_client.debug_dev = $stderr if ENV['BOTAKU_DEBUG_HTTP']

      if @opts[:token].match(/[\\\/.]/) || @opts[:token].count('-') != 2
        @opts[:token_path] = @opts[:token]
        @opts[:token] = File.read(@opts[:token]).strip
      end
    end

    def _self

      @rtm['self']
    end

    %w[ api chat rtm ].each do |mod|

      define_method mod do
        @modules[mod] ||= WebApiModule.new(self, mod)
      end
    end

    def on(type, &block)

      (@handlers[type] ||= []) << block
    end

    def run

      EM.run do
        @rtm = rtm.start
        @ws_client = Faye::WebSocket::Client.new(@rtm['url'])
        [ :open, :error, :close ].each do |event_type|
          @ws_client.on(event_type) { |event| dispatch(event_type, event) }
        end
        @ws_client.on(:message) { |event| dispatch_message(event) }
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

      args[:text] = args[:text]
        .gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')

      args[:mrkdwn] = true

      #chat.postMessage(args)

      args[:type] = 'message'
      args[:id] = next_id

      do_send(args)
    end

    def channels; @rtm['channels']; end
    def groups; @rtm['groups']; end
    def users; @rtm['users']; end

    def objects

      @objects ||=
        (channels + groups + users).inject({}) { |h, o| h[o['id']] = o; h }
    end

    def obj(o, cat=nil)

      if o.is_a?(Hash)
        cat = cat ? cat.to_s : nil
        o = o[cat]
      end

      case o
      when /\AU[0-9A-Z]+\z/
        users.find { |u| u['id'] == o }
      when /\A@[^\s]+\z/
        users.find { |u| u['name'] == o[1..-1] }
      when /\A[CG][0-9A-Z]+\z/
        (channels + groups).find { |c| c['id'] == o }
      when /\A#[^\s]+\z/
        (channels + groups).find { |c| c['name'] == o[1..-1] }
      else
        objects[o] ||
        objects.values.find { |x| x['name'] == o }
      end
    end

    def obj_id(o, cat=nil); h = obj(o, cat); h ? h['id'] : nil; end
    def obj_name(o, cat=nil); h = obj(o, cat); h ? h['name'] : nil; end

    def user(o); obj(o, :user); end
    def user_id(o); obj_id(o, :user); end
    def user_name(o); obj_name(o, :user); end
    def channel(o); obj(o, :channel); end
    def channel_id(o); obj_id(o, :channel); end
    def channel_name(o); obj_name(o, :channel); end

    def typing(args)

      do_send(type: 'typing', id: next_id, channel: channel_id(args[:channel]))
    end

    private

    def get(mod, meth, args)

      uri = args
        .inject(
          "#{@base_uri}/#{mod}.#{meth}?token=#{@opts[:token]}"
        ) { |u, (k, v)|
          u + "#{uri}&#{k}=#{escape(v)}"
        }

      @http_client.get(uri)
    end

    def do_send(args)

      @ws_client.send(JSON.dump(args) + "\n")
        # the \n seems to help flushing the buffer

      false # make sure that #say and #typing do not return true
    end

    def next_id

      @id = (@id ||= -1) + 1
    end

    class WebApiModule
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

      as.inject({}) do |h, a|
        if h[:channel] == nil && h[:channel] = channel_id(a)
          # cid just got assigned
        elsif h[:text] == nil && a.is_a?(String)
          h[:text] = a
        elsif a.is_a?(Hash)
          h.merge!(a)
        end
        h
      end
    end
  end
end

