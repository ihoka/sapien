# AGENTS.md
This file provides guidance to AI coding assistants working in this repository.

**Note:** CLAUDE.md, .clinerules, .cursorrules, .windsurfrules, .replit.md, GEMINI.md, and .github/copilot-instructions.md are symlinks to AGENTS.md in this project.

# Sapien

A Ruby on Rails 8.1 application using modern Hotwire (Turbo + Stimulus) for interactive UI, Solid adapters for caching/queuing/cable, and configured for production deployment with Kamal and Docker.

## Build & Commands

### Development
- **Setup**: `bin/setup` - Install dependencies and prepare database
- **Start server**: `bin/dev` - Run development server with asset watching
- **Rails console**: `bin/rails console` or `bin/rails c`
- **Database setup**: `bin/rails db:setup`
- **Database migrations**: `bin/rails db:migrate`
- **Database reset**: `bin/rails db:reset`
- **Generate scaffolds/models**: `bin/rails generate [generator] [name]`

### Testing
- **Run all tests**: `bin/rails test` or `bin/rails db:test:prepare test`
- **Run specific test**: `bin/rails test test/path/to/test_file.rb`
- **Run specific test line**: `bin/rails test test/path/to/test_file.rb:LINE_NUMBER`
- **Run system tests**: `bin/rails test:system` or `bin/rails db:test:prepare test:system`
- **Run all tests (CI)**: `bin/ci` - Runs security scans, linting, and all tests

### Linting & Security
- **Lint code**: `bin/rubocop` - Check code style (RuboCop with Rails Omakase config)
- **Auto-fix linting**: `bin/rubocop -a` - Auto-correct style violations
- **Security scan**: `bin/brakeman` - Scan for Rails security vulnerabilities
- **Audit gems**: `bin/bundler-audit` - Check for vulnerable gem versions
- **Audit JavaScript**: `bin/importmap audit` - Scan JavaScript dependencies

### Background Jobs
- **Run job worker**: `bin/jobs` - Start Solid Queue background job processor

### Deployment
- **Deploy with Kamal**: `bin/kamal deploy` - Deploy to production
- **Kamal setup**: `bin/kamal setup` - Initial server setup
- **Kamal console**: `bin/kamal app exec -i --reuse "bin/rails console"`
- **Build Docker image**: `docker build -t sapien .`
- **Run Docker container**: `docker run -d -p 80:80 -e RAILS_MASTER_KEY=<key> --name sapien sapien`

### Asset Management
- **Manage importmaps**: `bin/importmap` - Manage JavaScript imports

## Code Style

### Ruby Style Guide
This project follows the **Rails Omakase** Ruby style guide via RuboCop.

**Key Conventions:**
- **Indentation**: 2 spaces (no tabs)
- **String literals**: Prefer double quotes `"string"` over single quotes
- **Line length**: 120 characters maximum
- **Method naming**: Use `snake_case` for methods and variables
- **Class naming**: Use `CamelCase` for classes and modules
- **Constants**: Use `SCREAMING_SNAKE_CASE` for constants
- **File naming**: Use `snake_case.rb` for file names
- **Hash syntax**: Prefer modern syntax `{ key: value }` over `{ :key => value }`

### Rails Conventions
- **Controllers**: RESTful actions in order: index, show, new, create, edit, update, destroy
- **Models**: Keep business logic in models, not controllers
- **Fat models, skinny controllers**: Business logic belongs in models
- **Service objects**: Use for complex business logic spanning multiple models
- **Concerns**: Use for shared behavior across models/controllers
- **Strong parameters**: Always use strong parameters in controllers

### Hotwire/Turbo/Stimulus
- **Turbo Frames**: Use for partial page updates
- **Turbo Streams**: Use for real-time updates and complex UI changes
- **Stimulus controllers**: Keep JavaScript minimal and semantic
- **Data attributes**: Use `data-controller`, `data-action`, `data-target` for Stimulus
- **Progressive enhancement**: Ensure functionality works without JavaScript

### Import/Require Conventions
- **Rails autoloading**: Prefer autoloading over explicit `require` statements
- **Order**: Standard library, gems, local files
- **Importmap pins**: Define JavaScript modules in `config/importmap.rb`
- **JavaScript imports**: Use ES6 `import` syntax in `app/javascript/`

### Error Handling
- **Rescue in controllers**: Rescue specific exceptions, not all exceptions
- **Use ActiveRecord transactions**: Wrap multi-step database operations in transactions
- **Flash messages**: Use `flash[:notice]`, `flash[:alert]`, `flash[:error]`
- **Validation errors**: Handle in controllers with `if @model.save` checks
- **Log errors**: Use `Rails.logger.error` for production error tracking

## Testing

### Framework
- **Framework**: Minitest (Rails default)
- **System tests**: Capybara with Selenium WebDriver (headless Chrome)
- **Parallel execution**: Tests run in parallel using multiple processors

### Test File Patterns
- **Unit tests**: `test/models/*_test.rb`
- **Controller tests**: `test/controllers/*_test.rb`
- **Integration tests**: `test/integration/*_test.rb`
- **System tests**: `test/system/*_test.rb`
- **Helper tests**: `test/helpers/*_test.rb`
- **Mailer tests**: `test/mailers/*_test.rb`

### Testing Conventions
- **Test class naming**: `class ModelNameTest < ActiveSupport::TestCase`
- **Test method naming**: `test "descriptive test name"`
- **Fixtures**: Use YAML fixtures in `test/fixtures/*.yml`
- **Setup/teardown**: Use `setup` and `teardown` methods for test preparation
- **Assertions**: Use descriptive assertions (`assert_equal`, `assert_not_nil`, etc.)
- **System test assertions**: Use Capybara matchers (`assert_selector`, `assert_text`, etc.)

### Coverage Requirements
- **Models**: Comprehensive unit test coverage for all public methods
- **Controllers**: Test all actions and edge cases
- **System tests**: Test critical user flows end-to-end
- **Mailers**: Test email delivery and content

### Running Specific Tests
```bash
# Run a specific test file
bin/rails test test/models/user_test.rb

# Run a specific test by line number
bin/rails test test/models/user_test.rb:42

# Run tests matching a pattern
bin/rails test test/models/user_test.rb -n /validation/
```

### Testing Philosophy
**When tests fail, fix the code, not the test.**

Key principles:
- **Tests should be meaningful** - Avoid tests that always pass regardless of behavior
- **Test actual functionality** - Call the functions being tested, don't just check side effects
- **Failing tests are valuable** - They reveal bugs or missing features
- **Fix the root cause** - When a test fails, fix the underlying issue, don't hide the test
- **Test edge cases** - Tests that reveal limitations help improve the code
- **Document test purpose** - Each test should have a descriptive name explaining what it validates

## Security

### Authentication & Authorization
- **Password hashing**: Use `has_secure_password` from ActiveModel (requires bcrypt gem)
- **Session management**: Use Rails encrypted cookies for sessions
- **Authorization**: Implement proper authorization checks in controllers
- **CSRF protection**: Rails provides automatic CSRF protection (don't disable)

### Data Validation
- **Model validations**: Always validate user input at the model level
- **Strong parameters**: Use strong parameters to whitelist allowed attributes
- **SQL injection**: Use ActiveRecord query methods (avoid raw SQL)
- **XSS protection**: Rails auto-escapes HTML in views (use `raw` or `html_safe` carefully)

### Secret Management
- **Master key**: Store `config/master.key` securely (not in version control)
- **Credentials**: Use `bin/rails credentials:edit` for sensitive data
- **Environment variables**: Use for deployment-specific configuration
- **API keys**: Store in encrypted credentials, not in code

### Security Best Practices
- **Regular updates**: Keep Rails and gems updated for security patches
- **Security scanning**: Run `bin/brakeman` and `bin/bundler-audit` regularly
- **HTTPS only**: Use `config.force_ssl = true` in production
- **Content Security Policy**: Configure CSP headers in `config/initializers/content_security_policy.rb`
- **Rate limiting**: Implement rate limiting for sensitive endpoints
- **File uploads**: Validate file types and sizes for Active Storage uploads

## Directory Structure & File Organization

### Reports Directory
ALL project reports and documentation should be saved to the `reports/` directory:

```
sapien/
├── reports/              # All project reports and documentation
│   └── *.md             # Various report types
├── temp/                # Temporary files and debugging
└── [other directories]
```

### Report Generation Guidelines
**Important**: ALL reports should be saved to the `reports/` directory with descriptive names:

**Implementation Reports:**
- Phase validation: `PHASE_X_VALIDATION_REPORT.md`
- Implementation summaries: `IMPLEMENTATION_SUMMARY_[FEATURE].md`
- Feature completion: `FEATURE_[NAME]_REPORT.md`

**Testing & Analysis Reports:**
- Test results: `TEST_RESULTS_[DATE].md`
- Coverage reports: `COVERAGE_REPORT_[DATE].md`
- Performance analysis: `PERFORMANCE_ANALYSIS_[SCENARIO].md`
- Security scans: `SECURITY_SCAN_[DATE].md`

**Quality & Validation:**
- Code quality: `CODE_QUALITY_REPORT.md`
- Dependency analysis: `DEPENDENCY_REPORT.md`
- API compatibility: `API_COMPATIBILITY_REPORT.md`

**Report Naming Conventions:**
- Use descriptive names: `[TYPE]_[SCOPE]_[DATE].md`
- Include dates: `YYYY-MM-DD` format
- Group with prefixes: `TEST_`, `PERFORMANCE_`, `SECURITY_`
- Markdown format: All reports end in `.md`

### Temporary Files & Debugging
All temporary files, debugging scripts, and test artifacts should be organized in a `/temp` folder:

**Temporary File Organization:**
- **Debug scripts**: `temp/debug-*.rb`, `temp/analyze-*.rb`
- **Test artifacts**: `temp/test-results/`, `temp/coverage/`
- **Generated files**: `temp/generated/`, `temp/build-artifacts/`
- **Logs**: `temp/logs/debug.log`, `temp/logs/error.log`

**Guidelines:**
- Never commit files from `/temp` directory
- Use `/temp` for all debugging and analysis scripts created during development
- Clean up `/temp` directory regularly or use automated cleanup
- Include `/temp/` in `.gitignore` to prevent accidental commits

### Example `.gitignore` patterns
```
# Temporary files and debugging
/temp/
temp/
**/temp/
debug-*.rb
test-*.rb
analyze-*.sh
*-debug.*
*.debug

# Claude settings
.claude/settings.local.json

# Don't ignore reports directory
!reports/
!reports/**
```

### Claude Code Settings (.claude Directory)

The `.claude` directory contains Claude Code configuration files with specific version control rules:

#### Version Controlled Files (commit these):
- `.claude/settings.json` - Shared team settings for hooks, tools, and environment
- `.claude/commands/*.md` - Custom slash commands available to all team members
- `.claude/hooks/*.sh` - Hook scripts for automated validations and actions

#### Ignored Files (do NOT commit):
- `.claude/settings.local.json` - Personal preferences and local overrides
- Any `*.local.json` files - Personal configuration not meant for sharing

**Important Notes:**
- Claude Code automatically adds `.claude/settings.local.json` to `.gitignore`
- The shared `settings.json` should contain team-wide standards (linting, type checking, etc.)
- Personal preferences or experimental settings belong in `settings.local.json`
- Hook scripts in `.claude/hooks/` should be executable (`chmod +x`)

### Rails Directory Structure
```
sapien/
├── app/
│   ├── assets/          # Images, stylesheets
│   ├── controllers/     # Request handlers
│   ├── helpers/         # View helper modules
│   ├── javascript/      # Stimulus controllers, application JS
│   ├── jobs/            # Background jobs (Solid Queue)
│   ├── mailers/         # Email templates and logic
│   ├── models/          # ActiveRecord models
│   └── views/           # ERB/HTML templates
├── bin/                 # Executable scripts
├── config/              # Application configuration
│   ├── environments/    # Environment-specific config
│   ├── initializers/    # Initialization code
│   ├── locales/         # I18n translations
│   └── routes.rb        # URL routing
├── db/                  # Database schema and migrations
│   ├── migrate/         # Migration files
│   └── seeds.rb         # Seed data
├── lib/                 # Extended modules and custom code
├── log/                 # Application logs
├── public/              # Static files served directly
├── storage/             # Active Storage files
├── test/                # Test suite
├── tmp/                 # Temporary files
└── vendor/              # Third-party code (JavaScript via importmap)
```

## Configuration

### Environment Variables
- **RAILS_ENV**: Set environment (development, test, production)
- **DATABASE_URL**: Database connection string (production)
- **RAILS_MASTER_KEY**: Master key for encrypted credentials
- **REDIS_URL**: Redis connection (if using Redis instead of Solid adapters)
- **SECRET_KEY_BASE**: Session encryption key (auto-generated)

### Configuration Files
- **config/database.yml**: Database configuration (SQLite by default)
- **config/routes.rb**: URL routing definitions
- **config/application.rb**: Application-wide settings
- **config/environments/*.rb**: Environment-specific configuration
- **config/initializers/**: Initialization code run on app startup
- **config/importmap.rb**: JavaScript import map definitions
- **config/storage.yml**: Active Storage configuration
- **config/cable.yml**: Action Cable configuration (Solid Cable)
- **config/cache.yml**: Caching configuration (Solid Cache)
- **config/queue.yml**: Background job queue configuration (Solid Queue)

### Development Environment Setup
1. **Ruby version**: 3.4.5 (see `.ruby-version`)
2. **Rails version**: 8.1.0
3. **Database**: SQLite3 (>= 2.1)
4. **Install dependencies**: `bin/setup`
5. **Start server**: `bin/dev`

### Dependencies
- **Ruby**: 3.4.5
- **Rails**: 8.1.0
- **Database**: SQLite3
- **Web server**: Puma
- **JavaScript**: Importmap (no Node.js required)
- **CSS**: Propshaft asset pipeline
- **Hotwire**: Turbo + Stimulus for interactive UI
- **Solid adapters**: Solid Cache, Solid Queue, Solid Cable
- **Deployment**: Kamal + Docker + Thruster

### Rails 8 Features Used
- **Solid adapters**: Database-backed cache, queue, and cable (no Redis required)
- **Propshaft**: Modern asset pipeline
- **Importmap**: JavaScript without npm/webpack
- **Kamal**: Production deployment tool
- **Thruster**: HTTP proxy for Puma (X-Sendfile, caching)

## Agent Delegation & Tool Execution

### ⚠️ MANDATORY: Always Delegate to Specialists & Execute in Parallel

**When specialized agents are available, you MUST use them instead of attempting tasks yourself.**

**When performing multiple operations, send all tool calls (including Task calls for agent delegation) in a single message to execute them concurrently for optimal performance.**

#### Why Agent Delegation Matters:
- Specialists have deeper, more focused knowledge
- They're aware of edge cases and subtle bugs
- They follow established patterns and best practices
- They can provide more comprehensive solutions

#### Key Principles:
- **Agent Delegation**: Always check if a specialized agent exists for your task domain
- **Complex Problems**: Delegate to domain experts, use diagnostic agents when scope is unclear
- **Multiple Agents**: Send multiple Task tool calls in a single message to delegate to specialists in parallel
- **DEFAULT TO PARALLEL**: Unless you have a specific reason why operations MUST be sequential (output of A required for input of B), always execute multiple tools simultaneously
- **Plan Upfront**: Think "What information do I need to fully answer this question?" Then execute all searches together

#### Discovering Available Agents:
```bash
# Quick check: List agents if claudekit is installed
command -v claudekit >/dev/null 2>&1 && claudekit list agents || echo "claudekit not installed"

# If claudekit is installed, you can explore available agents:
claudekit list agents
```

#### Critical: Always Use Parallel Tool Calls

**Err on the side of maximizing parallel tool calls rather than running sequentially.**

**IMPORTANT: Send all tool calls in a single message to execute them in parallel.**

**These cases MUST use parallel tool calls:**
- Searching for different patterns (imports, usage, definitions)
- Multiple grep searches with different regex patterns
- Reading multiple files or searching different directories
- Combining Glob with Grep for comprehensive results
- Searching for multiple independent concepts with codebase_search_agent
- Any information gathering where you know upfront what you're looking for
- Agent delegations with multiple Task calls to different specialists

**Sequential calls ONLY when:**
You genuinely REQUIRE the output of one tool to determine the usage of the next tool.

**Planning Approach:**
1. Before making tool calls, think: "What information do I need to fully answer this question?"
2. Send all tool calls in a single message to execute them in parallel
3. Execute all those searches together rather than waiting for each result
4. Most of the time, parallel tool calls can be used rather than sequential

**Performance Impact:** Parallel tool execution is 3-5x faster than sequential calls, significantly improving user experience.

**Remember:** This is not just an optimization—it's the expected behavior. Both delegation and parallel execution are requirements, not suggestions.

## Rails-Specific Patterns

### Model Patterns
- **Validations**: Define at the model level
- **Callbacks**: Use sparingly (before_save, after_create, etc.)
- **Scopes**: Use for common query patterns
- **Associations**: Define relationships (has_many, belongs_to, etc.)
- **Concerns**: Extract shared behavior into concerns

### Controller Patterns
- **Before actions**: Use for authentication/authorization
- **Respond to formats**: Support HTML, JSON, Turbo Stream
- **Flash messages**: Provide user feedback
- **Redirect vs render**: Redirect after successful mutation, render on validation error

### View Patterns
- **Partials**: Extract reusable view components
- **Helpers**: Keep view logic in helpers, not views
- **Turbo Frames**: Scope updates to page sections
- **Turbo Streams**: Return multiple updates in one response
- **Form helpers**: Use `form_with` for modern forms

### Background Job Patterns
- **Job naming**: End with `Job` (e.g., `EmailNotificationJob`)
- **Queue naming**: Use descriptive queue names in `config/queue.yml`
- **Idempotency**: Design jobs to be safely retried
- **Error handling**: Use `retry_on` and `discard_on` for exceptions

## CI/CD Pipeline

### GitHub Actions Workflow
The project uses GitHub Actions for continuous integration (`.github/workflows/ci.yml`):

1. **Security Scanning**:
   - Ruby: `bin/brakeman` (Rails vulnerabilities)
   - Gems: `bin/bundler-audit` (vulnerable dependencies)
   - JavaScript: `bin/importmap audit` (JS dependencies)

2. **Linting**: `bin/rubocop -f github` (code style)

3. **Testing**:
   - Unit/integration tests: `bin/rails db:test:prepare test`
   - System tests: `bin/rails db:test:prepare test:system`
   - Screenshots from failed system tests uploaded as artifacts

### Pre-deployment Checklist
- All CI checks passing
- Security scans clean
- Test coverage maintained
- Database migrations tested
- Environment variables configured
- RAILS_MASTER_KEY secured

## Common Tasks

### Creating a New Feature
1. Generate scaffold: `bin/rails generate scaffold ModelName attribute:type`
2. Run migration: `bin/rails db:migrate`
3. Write tests: Add to `test/models/`, `test/controllers/`, `test/system/`
4. Implement feature: Update models, controllers, views
5. Add Stimulus controller if needed: `app/javascript/controllers/feature_controller.js`
6. Test: `bin/rails test`
7. Lint: `bin/rubocop -a`

### Database Operations
- **Create migration**: `bin/rails generate migration MigrationName`
- **Run migrations**: `bin/rails db:migrate`
- **Rollback migration**: `bin/rails db:rollback`
- **Reset database**: `bin/rails db:reset`
- **Seed database**: `bin/rails db:seed`

### Debugging
- **Rails console**: `bin/rails console`
- **Debug gem**: Add `debugger` statement in code, use `continue`, `next`, `step`
- **Rails logs**: `tail -f log/development.log`
- **Query logs**: Enable verbose query logging in console with `ActiveRecord::Base.logger = Logger.new(STDOUT)`

### Performance
- **Eager loading**: Use `includes`, `preload`, `eager_load` to avoid N+1 queries
- **Database indexes**: Add indexes for frequently queried columns
- **Fragment caching**: Cache view fragments with `cache` helper
- **Solid Cache**: Database-backed caching (no Redis needed)
- **Asset precompilation**: Assets precompiled in Docker build

## Additional Resources
- Rails Guides: https://guides.rubyonrails.org/
- Rails API Documentation: https://api.rubyonrails.org/
- Hotwire Documentation: https://hotwired.dev/
- Kamal Documentation: https://kamal-deploy.org/
- RuboCop Rails Omakase: https://github.com/rails/rubocop-rails-omakase/
