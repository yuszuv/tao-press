#!/usr/bin/env rake

namespace :news do
  desc "Export news data"
  task export: :environment do
    command = Application["commands.export_news"]
    logger = Application["logger"]
    settings = Application["settings"]

    puts "Starting news export..."

    case command.(path: settings.csv_output_path)
    in Success(*result)
      logger.ap result, :info
    in Failure[code, payload]
      puts "%-16s:%s" % [code, payload.message]
    end

    puts "News export completed!"
  end

  desc "Show application information"
  task info: :environment do
    puts "=" * 50
    puts "Container keys: #{Application.keys}"
    puts "Loader:         #{Application.autoloader}"
    puts "=" * 50
  end

  task :environment do
    require "dotenv/load"
    require "bundler/setup"
    require "dry/monads"
    require_relative "system/container"
    require_relative "system/import"

    include Dry::Monads[:result]

    # Initialize the application
    #
    Application.finalize!
  rescue ArgumentError => e
    puts "-" * 50
    puts
    puts e.message
    puts
    puts "-" * 50
    puts
    puts "invalid settings: please revise your setup, see .env and ./system/provider/settings"
  end
end

# Default task
task default: "news:export"
