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
    attr_reader :key
    attr_reader :e

    def initialize(key, error:)
      @key = key
      @e = error
      # super(:bar, msg: "foo")
    end
  end
end

Application.register(:csv_writer, CSVWriter.new)
