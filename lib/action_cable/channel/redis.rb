module ActionCable
  module Channel

    module Redis
      extend ActiveSupport::Concern

      included do
        on_unsubscribe :unsubscribe_from_redis_channels
        delegate :pubsub, to: :connection
      end

      def subscribe_to(redis_channel, callback = nil)
        callback ||= -> (message) { broadcast ActiveSupport::JSON.decode(message) }
        @_redis_channels ||= []
        @_redis_channels << [ redis_channel, callback ]

        logger.info "[ActionCable] Subscribing to the redis channel: #{redis_channel}"
        pubsub.subscribe(redis_channel, &callback)
      end

      protected
        def unsubscribe_from_redis_channels
          if @_redis_channels
            @_redis_channels.each do |channel, callback|
              logger.info "[ActionCable] Unsubscribing from the redis channel: #{channel}"
              pubsub.unsubscribe_proc(channel, callback)
            end
          end
        end
    end

  end
end