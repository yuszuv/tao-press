# frozen_string_literal: true

require "dry/monads"

# Global error handling service that can be configured with different actions
# for different types of errors
class ErrorHandler
  include Dry::Monads[:result]

  def initialize(logger:, notifiers: [])
    @logger = logger
    @notifiers = notifiers
  end

  # Handle an error with configured actions
  def call(code, error)
    error_type = determine_error_type(error)

    notify_error(error, error_type, code)

    # Log the error
    # or: don't log, because we don't want the user to see this
    # log_error(error, error_type, code)
  end

  private

  attr_reader :logger, :notifiers

  def determine_error_type(error)
    case error
    when Application::Error
      raise "this should not happen. errors should be globally captured in app"
    else
      :critical
    end
  end

  def log_error(error, error_type, context)
    log_level = error_type == :critical ? :error : :warn

    logger.public_send(log_level, "Error handled")
    logger.public_send(log_level, error.message)
    logger.public_send(log_level, error.backtrace&.first(5).join("\n"))
  end

  def notify_error(error, _error_type, code)
    notifiers.each do |notifier|
      begin
        notifier.notify(code, error)
      rescue => e
        logger.error("Failed to send notification", {
          notifier: notifier.class.name,
          error: e.message
        })
      end
    end
  end
end
