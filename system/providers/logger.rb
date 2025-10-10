# frozen_string_literal: true
Application.register_provider(:logger) do
  prepare do
    require "logger"
  end

  start do
    require "logger"
    logger = Logger.new($stdout)
    logger.level = ENV["LOG_LEVEL"]&.upcase == "DEBUG" ? Logger::DEBUG : Logger::INFO
    register(:logger, logger)
  end
end
