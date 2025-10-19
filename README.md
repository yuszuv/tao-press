# TaoPress <> WordPress Mapper

A Ruby service that extracts news feeds from a Contao CMS instance and transforms them into CSV and Markdown formats ready for WordPress import.

## Configuration

Configuration is managed via environment variables, typically set in a `.env` file at the project root.

Refer to [`system/providers/settings.rb`](system/providers/settings.rb) for the complete list of available settings, defaults, and descriptions.

The application automatically loads `.env` if present, or you can provide variables directly in your environment.

## Running It

### CLI Interface

The application provides a modern CLI interface via the `tao_press` command:

```bash
# Export all news items (default)
./bin/tao_press export

# Export with options
./bin/tao_press export --limit=10 --output=/tmp/news.csv --markdown_output=/tmp/markdown

# Show application information
./bin/tao_press info

# Show version
./bin/tao_press version
```

### Rake Tasks

You can also use traditional rake tasks:

```bash
# Export news data (default task)
rake

# Show application information
rake news:info
```

**Note**: The rake tasks currently have a parameter mismatch and may not work correctly. Use the CLI interface for reliable operation.

## Output Formats

The application exports news data in two formats:

### CSV Export

* **Purpose**: WordPress import-ready format
* **Location**: Configured via `CSV_OUTPUT_PATH` setting
* **Features**: Includes all necessary fields for WordPress import, handles file attachments and metadata

### Markdown Export

* **Purpose**: Human-readable documentation and backup
* **Location**: Configured via `MARKDOWN_OUTPUT_PATH` setting  
* **Features**: Individual markdown files per news item, preserves formatting and media references

## System Architecture

This application follows **Hexagonal Architecture** (Ports and Adapters) principles, providing a clean separation between business logic and external concerns:

### Core Domain (Center)

* **Entities** (`app/entities/`): Domain objects representing business concepts (Post, Author, File)
* **Commands** (`app/commands/`): Use cases that orchestrate business operations
* **Mappers** (`app/mappers/`): Transform data between different representations
* **Serializers** (`app/serializers/`): Convert domain objects to output formats

### Infrastructure (Outer Layer)

* **Repositories** (`app/repositories/`): Data access layer implementing domain interfaces
* **Providers** (`system/providers/`): External service configurations (database, logging, settings)
* **Container** (`system/container.rb`): Dependency injection container using dry-system

### Key Architectural Benefits

* **Testability**: Business logic is isolated from external dependencies
* **Flexibility**: Easy to swap data sources or output formats
* **Maintainability**: Clear separation of concerns with well-defined boundaries
* **Dependency Inversion**: Core domain doesn't depend on infrastructure details

### Data Flow

```text
Contao DB → Repositories → Entities → Mappers → Serializers → CSV + Markdown
```

The application uses **dry-rb** ecosystem for:

* **dry-system**: Dependency injection and component lifecycle
* **dry-struct**: Type-safe domain entities
* **dry-transformer**: Data transformation pipelines
* **dry-types**: Type validation and coercion

## Error Handling & Notifications

The application includes a comprehensive error handling system with multiple notification channels:

### Available Notifiers

* **Slack Notifier**: Sends error alerts to Slack channels
* **Email Notifier**: Sends error alerts via email
* **Signal Notifier**: Sends error alerts via Signal messenger using [signal-cli](https://github.com/AsamK/signal-cli)

### Notifier Configuration

Configure notifiers using environment variables:

```bash
# Core application settings
DATABASE_URL=mysql://user:pass@localhost:3306/db-name
LOG_LEVEL=INFO  # DEBUG, INFO, WARN, ERROR, FATAL, TRACE, UNKNOWN
CSV_OUTPUT_PATH=export.csv
MARKDOWN_OUTPUT_PATH=./markdown_output
WORDPRESS_UPLOADS_PREFIX=  # Optional prefix for WordPress uploads

# Slack notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
SLACK_CHANNEL=#alerts

# Email notifications
ERROR_EMAIL_RECIPIENTS=admin@example.com,dev@example.com
ERROR_EMAIL_FROM=noreply@example.com

# Signal notifications
SIGNAL_ACCOUNT=+1234567890  # Your Signal account (international format)
SIGNAL_RECIPIENTS=+0987654321,+1122334455  # Recipients (comma-separated)
SIGNAL_CLI_PATH=/usr/local/bin/signal-cli  # Optional: custom signal-cli path
```

### Signal Setup

To use Signal notifications, you need to:

1. Install [signal-cli](https://github.com/AsamK/signal-cli)
2. Link your device: `signal-cli -u <phone_number> link`

The Signal notifier will only send alerts for critical errors by default.
