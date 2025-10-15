# frozen_string_literal: true

# Example error notifier for email
# This is a template - you would need to implement actual email sending
class ErrorNotifiers::EmailNotifier
  def initialize(recipients:, from: "noreply@example.com")
    @recipients = Array(recipients)
    @from = from
  end

  def notify(error, error_type, context)
    return unless should_notify?(error_type)
    
    subject = build_subject(error, error_type)
    body = build_body(error, error_type, context)
    
    send_email(subject, body)
  end

  private

  attr_reader :recipients, :from

  def should_notify?(error_type)
    # Notify for both critical and recoverable errors
    [:critical, :recoverable].include?(error_type)
  end

  def build_subject(error, error_type)
    "TaoPress Error Alert: #{error_type.to_s.upcase} - #{error.class.name}"
  end

  def build_body(error, error_type, context)
    <<~EMAIL
      Error Type: #{error_type.to_s.upcase}
      Error Class: #{error.class.name}
      Message: #{error.message}
      
      Context:
      #{context.to_json}
      
      Backtrace:
      #{error.backtrace&.first(10)&.join("\n")}
      
      Time: #{Time.now}
    EMAIL
  end

  def send_email(subject, body)
    # This is a placeholder - you would implement actual email sending here
    # require 'mail'
    # 
    # Mail.deliver do
    #   from from
    #   to recipients
    #   subject subject
    #   body body
    # end
    
    puts "📧 EMAIL NOTIFICATION (simulated):"
    puts "To: #{recipients.join(', ')}"
    puts "From: #{from}"
    puts "Subject: #{subject}"
    puts "Body: #{body.lines.first(3).join}"
    puts "---"
  end
end
