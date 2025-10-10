# frozen_string_literal: true
require "dry/system"
require "pathname"

class Application < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch("RACK_ENV", :development).to_sym }
  use :zeitwerk #, debug: true

  configure do |config|
    # config.root = Pathname(__dir__).join("..").realpath
    config.component_dirs.add "lib"
  end
end
