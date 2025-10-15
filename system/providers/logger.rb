# frozen_string_literal: true
Application.register_provider(:logger) do
  prepare do
    require "logger"
    require "awesome_print"
  end

  start do
    require "logger"
    logger = Logger.new($stdout)
    logger.level = ENV["LOG_LEVEL"]&.upcase == "DEBUG" ? Logger::DEBUG : Logger::INFO

    logger.formatter = proc { |_severity, time, _progname, msg|
      # [time, "-" * 50, msg].zip(["\n"].cycle).join
      msg + "\n"
    }
    register(:logger, logger)
  end
end
