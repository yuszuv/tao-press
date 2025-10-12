# frozen_string_literal: true
Application.register_provider(:system_administrator) do
  prepare do
    # require 'signal'
  end

  start do
    target.start :logger

    subscribers = []

    account = target[:settings].signal_account
    recipients = target[:settings].signal_recipients

    if account && recipients.any?
      # TODO: check authentication

      subscribers << ErrorNotifiers::SignalNotifier.new(**{
        account:,
        recipients:,
      })
    end

    error_handler = ErrorHandler.new(logger: target[:logger], notifiers: subscribers)

    register(:error_handler, error_handler)
  end
end

