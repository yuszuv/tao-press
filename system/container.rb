# frozen_string_literal: true
require "dry/system"
require "pathname"

class Application < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch("RACK_ENV", :development).to_sym }
  use :zeitwerk #, debug: true

  configure do |config|
    config.component_dirs.add "lib" do |dir|
      dir.auto_register = false
    end

    config.component_dirs.add "app"
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
