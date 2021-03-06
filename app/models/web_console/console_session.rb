module WebConsole
  # Manage and persist (in memory) WebConsole::Slave instances.
  class ConsoleSession
    include ActiveModel::Model

    # In-memory storage for the console sessions. Session preservation is
    # troubled on servers with multiple workers and threads.
    INMEMORY_STORAGE = {}

    # Base error class for ConsoleSession specific exceptions.
    #
    # Provides #to_json implementation, so all subclasses are JSON
    # serializable.
    class Error < StandardError
      def to_json(*)
        { error: to_s }.to_json
      end
    end

    # Raised when trying to find a session that is no longer in the in-memory
    # session storage.
    NotFound = Class.new(Error)

    # Raised when an operation transition to an invalid state.
    Invalid = Class.new(Error)

    class << self
      # Finds a session by its pid.
      #
      # Raises WebConsole::ConsoleSession::Expired if there is no such session.
      def find(pid)
        INMEMORY_STORAGE[pid.to_i] or raise NotFound, 'Session unavailable'
      end

      # Creates an already persisted consolse session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create(console_command='rails console')
        new({console_command: console_command}).persist
      end
    end

    def initialize(attributes = {})
      @slave = WebConsole::Slave.new(attributes[:console_command])
    end

    # Explicitly persist the model in the in-memory storage.
    def persist
      INMEMORY_STORAGE[pid] = self
    end

    # Returns true if the current session is persisted in the in-memory storage.
    def persisted?
      self == INMEMORY_STORAGE[pid]
    end

    # Returns an Enumerable of all key attributes if any is set, regardless if
    # the object is persisted or not.
    def to_key
      [pid] if persisted?
    end

    private

      def method_missing(name, *args, &block)
        if @slave.respond_to?(name)
          @slave.public_send(name, *args, &block)
        else
          super
        end
      rescue ArgumentError => exc
        raise Invalid, exc
      end

      def respond_to_missing?(name, include_all = false)
        @slave.respond_to?(name) or super
      end
  end
end
