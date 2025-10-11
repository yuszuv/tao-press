# LPV Contao <> Wordpress Mapper

A Ruby service that extracts news feeds from a Contao CMS instance and transforms them into CSV format ready for WordPress import.


## Configuration

Configuration is managed via environment variables, typically set in a `.env` file at the project root.

Refer to [`system/providers/settings.rb`](system/providers/settings.rb) for the complete list of available settings, defaults, and descriptions.

The application automatically loads `.env` if present, or you can provide variables directly in your environment.


## Running It

Run the (default) `rake` task:

```bash
rake
```


### Available Tasks

- `rake news:export` - Export news data to CSV (default task)
- `rake news:info` - Show application information and container keys

## System Architecture

This application follows **Hexagonal Architecture** (Ports and Adapters) principles, providing a clean separation between business logic and external concerns:

### Core Domain (Center)
- **Entities** (`app/entities/`): Domain objects representing business concepts (Post, Author, File)
- **Commands** (`app/commands/`): Use cases that orchestrate business operations
- **Mappers** (`app/mappers/`): Transform data between different representations
- **Serializers** (`app/serializers/`): Convert domain objects to output formats

### Infrastructure (Outer Layer)
- **Repositories** (`app/repositories/`): Data access layer implementing domain interfaces
- **Providers** (`system/providers/`): External service configurations (database, logging, settings)
- **Container** (`system/container.rb`): Dependency injection container using dry-system

### Key Architectural Benefits
- **Testability**: Business logic is isolated from external dependencies
- **Flexibility**: Easy to swap data sources or output formats
- **Maintainability**: Clear separation of concerns with well-defined boundaries
- **Dependency Inversion**: Core domain doesn't depend on infrastructure details

### Data Flow
```
Contao DB → Repositories → Entities → Mappers → Serializers → CSV
```

The application uses **dry-rb** ecosystem for:
- **dry-system**: Dependency injection and component lifecycle
- **dry-struct**: Type-safe domain entities
- **dry-transformer**: Data transformation pipelines
- **dry-types**: Type validation and coercion