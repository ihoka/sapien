# Sapien

An intelligent AI firewall and companion that helps you navigate the increasingly AI-dominated digital landscape by distinguishing between human and AI interactions across multiple communication platforms.

## Purpose

Sapien acts as your personal gatekeeper in social and professional networks, ensuring you spend your time and attention on genuine human connections. As AI agents become more prevalent across social media and messaging platforms, Sapien helps you maintain authentic human interactions by:

- **Multi-Platform Management**: Monitors interactions across X (Twitter), WhatsApp, Telegram, Zangi, Viber, and other platforms
- **AI Detection**: Analyzes communication patterns to distinguish between human and AI contacts
- **Confidence Scoring**: Assigns probability scores indicating the likelihood that a contact is human
- **Intelligent Filtering**: Filters social media interactions so you only engage with verified humans
- **Contact Management**: Maintains a database of contacts with their human-likelihood scores
- **Privacy First**: All analysis happens on your infrastructure, keeping your data private

## Problem Statement

The digital world is increasingly populated by AI agents, bots, and automated systems posing as humans. These entities consume attention, create noise in social feeds, and make it difficult to maintain meaningful human connections. Sapien solves this by providing an intelligent layer that identifies and filters AI interactions, allowing you to focus on what matters: genuine human relationships.

## Technology Stack

- **Rails 8.1**: Modern Ruby on Rails framework with Hotwire
- **Solid Adapters**: Database-backed cache, queue, and cable (no Redis dependency)
- **Hotwire**: Turbo + Stimulus for real-time, reactive UI
- **Kamal**: Production-ready deployment with Docker
- **Ruby 3.4.5**: Latest Ruby with performance improvements

## Getting Started

### Prerequisites

- Ruby 3.4.5
- SQLite3 2.1+
- Docker (for deployment)

### Setup

```bash
# Install dependencies and setup database
bin/setup

# Start the development server
bin/dev

# Run tests
bin/rails test

# Run security scans
bin/brakeman
bin/bundler-audit
```

## Development

### Running Tests

```bash
# All tests
bin/rails test

# Specific test file
bin/rails test test/models/contact_test.rb

# Specific test by line number
bin/rails test test/models/contact_test.rb:42

# System tests
bin/rails test:system
```

### Code Quality

```bash
# Lint with RuboCop (Rails Omakase style)
bin/rubocop

# Auto-fix style issues
bin/rubocop -a

# Run full CI suite
bin/ci
```

## Deployment

Sapien uses Kamal for zero-downtime deployments:

```bash
# Initial setup
bin/kamal setup

# Deploy
bin/kamal deploy

# Access production console
bin/kamal app exec -i --reuse "bin/rails console"
```

## Contributing

See [AGENTS.md](AGENTS.md) for development guidelines, code style, and testing conventions.

## License

This project is licensed under the Business Source License 1.1. See [LICENSE](LICENSE) for details.

The licensed work will convert to the Apache License, Version 2.0 on 2029-01-14.
