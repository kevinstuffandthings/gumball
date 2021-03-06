# frozen_string_literal: true

require "logger"

module Gumball
  class Dispenser
    attr_reader :ttl

    # Set up a new dispenser.
    # @param ttl [???]
    # @param block
    # @return [Dispenser]
    def initialize(ttl, logger: nil, &block)
      @ttl = ttl
      @logger = logger || Logger.new("/dev/null")
      @last_refreshed = nil
      @refresh_block = block
      @on_change_block = nil
    end

    # Add a block to execute upon detection of a change in the item.
    # The block should accept the old/new versions of the item.
    # @param block
    # @return [self]
    def on_change(&block)
      @on_change_block = block
      self
    end

    # Retrieve an item from the dispenser. On the first retrieval, a
    # new instance of the item will be created, and returned until deemed
    # expired by the specified `ttl`.
    # @return item
    def item
      now = Time.now
      old_item = @_item
      @_item = nil if expired?
      unless @_item
        @_item = @refresh_block.call
        @logger.info "#{self.class} refreshed, new_value=#{@_item}"
        if @last_refreshed && @on_change_block && (old_item != @_item)
          @logger.debug "#{self.class} executing on_change block; detected change from previous value #{old_item}"
          @on_change_block.call(old_item, @_item)
        end
        @last_refreshed = now
      end
      @_item
    end

    private

    def expired?
      return false unless @last_refreshed
      @last_refreshed + ttl < Time.now
    end
  end
end
