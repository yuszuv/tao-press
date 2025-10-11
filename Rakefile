#!/usr/bin/env rake
namespace :news do
  desc "Export news data"
  task export: :environment do
    command = Application["commands.export_news"]

    puts "Starting news export..."
    command.()
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
    require_relative "system/container"
    require_relative "system/import"

    # Initialize the application
    Application.finalize!
  end
end

# Default task
task default: "news:export"
