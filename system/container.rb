# frozen_string_literal: true
require "dry/system"
require "dry/monitor"
require "dry/events"
require "pathname"

require_relative "./error_handler"

class Application < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch("RACK_ENV", :development).to_sym }
  use :zeitwerk #, debug: true
  use :monitoring

  configure do |config|
    config.component_dirs.add "lib" do |dir|
      dir.auto_register = false
    end

    config.component_dirs.add "app"
  end

  after(:finalize) do 
    settings = resolve("settings")

    subscribers = []

    account = settings.signal_account
    recipients = settings.signal_recipients

    if account && recipients.any?
      # TODO: check authentication
      subscribers << Notifiers::SignalNotifier.new(**{
        account:,
        recipients:,
      })
    end

    error_handler = ErrorHandler.new(logger: resolve(:logger), notifiers: subscribers)

    register(:error_handler, error_handler)
  end

  class Error < StandardError
    attr_reader :message
    attr_reader :key
    attr_reader :error

    def initialize(message, key = :unknown, error: nil)
      super(message)
      @message = message
      @key = key
      @error = error
    end
  end

  class ArgumentError < Error
  end
end
