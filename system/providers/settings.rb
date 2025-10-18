require "dry/system"
require "dry/system/provider_sources/settings"
require "dry/types"

# Configuration via .env files
# 
# This provider reads settings from environment variables. To configure:
# 1. Create a .env file in the project root
# 2. Add the environment variables (see comments below for each setting)
# 3. The dotenv gem (loaded in Rakefile) will automatically load .env
#
# Example .env file:
#   DATABASE_URL=mysql://user:pass@localhost:3306/db-name
#   LOG_LEVEL=DEBUG
#   CSV_OUTPUT_PATH=export.csv
#
# You can also set these as system environment variables or in your shell profile.

Application.register_provider(:settings, from: :dry_system) do
  before :prepare do
    require_relative "../../lib/types"
  end

  settings do
    # ENV: DATABASE_URL (required)
    # Example: mysql://user:pass@localhost:3306/db-name
    setting :database_url, constructor: Types::String.constrained(filled: true)

    # ENV: LOG_LEVEL (optional) – one of: DEBUG, INFO (default), WARN, ERROR, FATAL, TRACE, UNKNOWN
    # Default is :info. Set LOG_LEVEL=DEBUG to enable verbose logging; SQL queries
    # are logged when the logger level is :debug (see db provider).
    setting :log_level, default: :info, constructor: Types::Symbol
      .constructor { |value| value.to_s.downcase.to_sym }
      .enum(:trace, :unknown, :error, :fatal, :warn, :info, :debug)

    # ENV: CSV_OUTPUT_PATH (required)
    # Output path for the generated CSV (e.g., export.csv)
    setting :csv_output_path, constructor: Types::String.constrained(filled: true)
    setting :wordpress_uploads_prefix, default: "", constructor: Types::String
    # ENV: MARKDOWN_OUTPUT_PATH (required)
    # Output directory for the generated Markdown files (e.g., ./markdown_output)
    setting :markdown_output_path, constructor: Types::String.constrained(filled: true)

    setting :signal_account, constructor: Types::String.optional
    setting :signal_recipients, default: "", constructor: ->(xs) { xs.split(",").then{ Types::Array.of(Types::String)[_1] } }
    # setting :signal_recipients, default: "", constructor: ->(xs) { xs.split(",").then{ Types::Array.of(Types::Email)[_1] } }
    setting :signal_cli_path, constructor: Types::String.optional
  end
end
