# frozen_string_literal: true

# Error notifier for Signal messenger using signal-cli
class Notifiers::SignalNotifier
  include Import['settings']

  def initialize(account:, recipients:, **kwargs)
    super(**kwargs)
    @recipients = recipients
    @account = account
    @signal_cli_path = settings.signal_cli_path or raise Application::ArgumentError, "signal_cli_path not given"
  end

  def notify(code, error)
    return unless should_notify?(error)

    message = build_message(code, error)
    send_to_signal(message)
  end

  private

  attr_reader :account, :recipients, :signal_cli_path

  def should_notify?(error)
    # # Only notify for critical errors by default
    # error_type == :critical
    error.class < StandardError
  end

  def build_message(code, error)
    str = <<~MESSAGE
      🚨 Application Error Alert

      Code: #{code}
      Class: #{error.class.name}
      Message: #{error.message}
      Backtrace:
      #{error.backtrace.join("\n")}

      Time: #{Time.now}
    MESSAGE

    str
  end

  def send_to_signal(message)
    recipients.each do |recipient|
      begin
        # Use signal-cli to send message
        # Format: signal-cli -u ACCOUNT send -m "MESSAGE" RECIPIENT
        command = [
          signal_cli_path,
          "-u", account,
          "send",
          "-m", message.strip,
          recipient
        ]

        # Execute the command
        system(*command)

        if $?.success?
          puts "📱 SIGNAL NOTIFICATION sent to #{recipient}"
        else
          puts "❌ Failed to send Signal notification to #{recipient}"
        end
      rescue => e
        puts "❌ Error sending Signal notification to #{recipient}: #{e.message}"
      end
    end
  end
end
