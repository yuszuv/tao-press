# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  # Store HTTP interactions in this directory
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  
  # Use webmock for HTTP stubbing
  config.hook_into :webmock
  
  # Filter sensitive data before recording
  config.filter_sensitive_data('<API_KEY>') { ENV['OPENAI_API_KEY'] }
  config.filter_sensitive_data('<API_KEY>') { ENV['ANTHROPIC_API_KEY'] }
  
  # Allow real HTTP requests when VCR is turned off
  config.allow_http_connections_when_no_cassette = false
  
  # Configure request matching
  config.default_cassette_options = {
    record: :once,  # Only record new interactions once, then replay
    match_requests_on: [:method, :uri, :body]
  }
end

