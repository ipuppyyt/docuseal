# Project Context: DocuSeal

claude --resume e853e1c3-404c-4020-acdb-631166fd3461 (Model: qwen3.5)

**DocuSeal** is an open source digital document signing and processing platform built on Ruby on Rails 8.1.3.

## Overview

DocuSeal is a multi-tenant SaaS application that enables users to:
- Create and customize PDF forms with WYSIWYG field builders
- Fill and sign documents online on any device
- Manage multiple submitters per document
- Handle document templates and attachments
- Integrate with external systems via API and webhooks
- Store files on disk, AWS S3, Google Storage, or Azure Cloud

### Key Stats
- **Ruby Version**: 3.4.x
- **Rails Version**: 8.1.3
- **Database**: PostgreSQL (with SQLite for dev/test), supports MySQL
- **Supported Languages**: 7 UI languages, 14 language options for signing
- **Architecture**: Multi-tenant with tenant isolation
- **Frontend**: React SPA (shakapacker), Webpack

---

## Core Technology Stack

### Backend (Ruby on Rails)
- **Framework**: Rails 8.1.3
- **Authentication**: Devise + Devise-TwoFactor (OTP/2FA support)
- **Authorization**: Cancancan (ability-based)
- **Database**: PostgreSQL, MySQL (production), SQLite (development)
- **PDF Generation**: HexaPDF, Ruby-vips (image processing)
- **File Storage**: Active Storage (S3, Azure, Google Cloud, Local)
- **Background Jobs**: Sidekiq
- **API Format**: JSON (active format)
- **Caching**: Redis (via connection_pool)

### Frontend
- **JavaScript Framework**: React 18+ (via ShakaPack)
- **CSS Framework**: Tailwind CSS
- **State Management**: Context API
- **Build Tool**: Webpack
- **TypeScript**: Optional, via babel

### Third-Party Integrations
- **Cloud Storage**: AWS S3, Google Cloud Storage, Azure Blob
- **Email**: SMTP (via mailers)
- **SMS**: Twilio (pro feature)
- **SSO**: SAML (pro feature)
- **MCP**: Model Context Protocol support

---

## Key Directories

### `app/controllers/` - Controller Layer
All 40+ controllers define routes and business logic:

| Controller Group | Purpose | Key Controllers |
|---|---|---|
| **API** | RESTful endpoints for submissions, templates, users | `submissions`, `templates`, `api/submissions` |
| **Documents** | Document generation and management | `template_documents`, `preview_document_page` |
| **Forms** | Form submission handling | `submit_form`, `start_form` |
| **Settings** | User preferences and account config | `api_settings`, `storage_settings`, `email_smtp_settings` |
| **Dashboard** | Admin dashboard and management | `dashboard`, `submissions_dashboard` |
| **System** | Utility controllers | `mcp_controller`, `pwa`, `embed_scripts` |

### `app/models/` - Data Models
**30+ Models** representing core entities:

| Model | Description | Key Associations |
|---|---|---|
| `User` | Platform users with roles (admin/default) | Templates, folders, emails |
| `Account` | Multi-tenant account isolation | Users, configs, folders |
| `Template` | Document form templates | Folders, submitters, fields |
| `Submission` | Individual document submissions | Templates, submitters |
| `Submitter` | Individual signers on a document | Submissions, templates |
| `TemplateFolder` | Hierarchical template organization | Templates (parent) |
| `EncryptedUserConfig` | Encrypted user settings | Users |
| `WebhookUrl` | Webhook endpoint configuration | Accounts |
| `WebhookEvent` | Webhook event tracking | WebhookUrls |
| `EmailMessage` | Email content tracking | Accounts |
| `CompletedDocument` | Finished document tracking | Submitters |
| `DynamicDocument` | Dynamic PDF generation | Templates |
| `AccessDenied` | Access control denials | Users |
| `SearchEntry` | Full-text search indexing | Record polymorphism |
| `MCPToken` | Model Context Protocol auth | Users |
| `EncryptedConfig` | Account-level secrets | Accounts |
| `AccountLinkedAccount` | Third-party OAuth linking | Accounts |
| `CustomFont` | Custom font management | Users |

### `app/views/` - View Layer
**200+ ERB views** organized by controller/action:

- `dashboard/` - Admin dashboard views
- `submissions/` - Submission listing and detail
- `templates/` - Template management
- `api/` - API JSON responses
- `submit_form/` - Public form submission flows
- `devise/mailer/` - Email templates
- `icons/` - SVG icon definitions

### `app/helpers/` - View Helpers
Provides helper methods for:
- Pagination (Pagy)
- Form helpers
- URL generation
- Permission checks (Cancancan)
- Date formatting

### `app/mailers/` - Email System
5 Mailers for different email types:
- `ApplicationMailer` - General emails
- `SettingsMailer` - Settings notifications
- `SubmitterMailer` - Submitter emails
- `TemplateMailer` - Template notifications
- `UserMailer` - User lifecycle emails

### `app/services/` - Business Logic
Service objects encapsulating complex operations:
- Document generation
- Email delivery
- File processing
- Notification sending

### `config/` - Configuration
- `routes.rb` - Rails routing (150+ routes)
- `database.yml` - Database connections
- `environment.rb` - Rails initialization
- `locales/i18n.yml` - i18n translations

### `lib/` - Library
- Custom middleware
- Path helpers
- Utility modules

---

## Core Features

### 1. Template Management
- Create PDF forms with 12+ field types
- Drag-and-drop field builder
- HTML API for custom fields
- Document embedding support
- Template sharing via links
- Versioned templates
- Folders for organization

### 2. Submission Flow
- Dynamic form filling
- Multi-submitter documents
- Email invitations
- SMS verification (pro)
- 2FA authentication
- Document preview before signing
- Audit trail generation

### 3. Document Processing
- PDF merging (HexaPDF)
- Signature embedding
- Timestamp server integration
- PDF signature verification
- Dynamic document generation
- Version control

### 4. Storage & Delivery
- File storage backends: S3, Azure, GCS, Local
- Expiring document URLs
- Email notifications
- SMS notifications (pro)
- Webhook callbacks

### 5. Multi-Tenancy
- Tenant isolation via `account_id`
- Custom fields per account
- API keys per account
- Encrypted tenant configs
- Multi-currency support (via settings)

---

## Database Schema Highlights

### Tenant Model (`accounts`)
```ruby
- uuid: unique tenant identifier
- name: account name
- locale: default language
- timezone: UTC offset
- archived_at: soft delete
```

### User Model (`users`)
```ruby
- role: 'admin' (default) or 'user'
- email: unique
- encrypted_password
- otp_secret: for 2FA
- otp_required_for_login: boolean
- archived_at: soft delete
```

### Template Model (`templates`)
```ruby
- fields: JSON array of field definitions
- schema: JSON schema
- source: 'native' (builder) or 'api' (HTML/PDF)
- shared_link: boolean for sharing
- slug: unique identifier
- archived_at: soft delete
```

### Submission Model (`submissions`)
```ruby
- template_id: FK
- slug: unique (base58)
- expire_at: optional expiry
- variables: JSON filled values
- template_fields: JSON field mappings
- source: 'link'|'bulk'|'api'|'embed'|'invite'
- preferences: JSON settings
- archived_at: soft delete
```

### Submitter Model (`submitters`)
```ruby
- email, name, phone: contact info
- values: JSON filled form values
- preferences: submitter settings
- completed_at/declined_at: status
- sent_at, opened_at: timestamps
- verification_method: 'email'|'sms'|'2fa'
```

### Completed Submitters (`completed_submitters`)
Tracks first submitters for multi-submitter docs:
```ruby
- account_id, submission_id, submitter_id, template_id
- completed_at: timestamp
- is_first: boolean (for deduplication)
- source: 'email'|'api'|'bulk'
```

---

## Security & Authorization

### Authentication
- **Devise** with two-factor auth
- **OTP/2FA** via TOTP (rotp gem)
- **Password reset** via email
- **Session management** with remember me

### Authorization
- **Cancancan** for ability-based auth
- **Role-based**: admin vs regular users
- **Tenant isolation**: `account_id` on all tables
- **Access tokens**: SHA256 hashed
- **MCP tokens**: Scoped access control

### Security Features
- **Content Security Policy** with nonces
- **SQL injection prevention** via AR
- **XSS protection** via escaping
- **CSRF tokens** on all forms
- **Brakeman** static analysis
- **Bullet** N+1 query detection
- **Secrets encryption** in config

---

## API Design

### RESTful API Structure
```
GET  /api/templates                    - List templates
POST /api/templates                    - Create template
GET  /api/templates/:id                - Show template
PATCH /api/templates/:id               - Update template
DELETE /api/templates/:id              - Delete template

GET  /api/submissions                  - List submissions
POST /api/submissions                  - Create submission
GET  /api/submissions/:id              - Show submission
DELETE /api/submissions/:id            - Delete submission

POST /api/submissions/:id/emails       - Send invitation
GET  /api/submissions/:id/documents    - List documents
GET  /api/submissions/:slug/d          - Public form preview
POST /api/tools/merge                  - Merge documents
POST /api/tools/verify                 - Verify signature
```

### Webhooks
```ruby
- WebhookUrl: defines endpoint + events + secret
- WebhookEvent: tracks delivery attempts
- WebhookAttempt: failure logging
```

**Events**: `submission.completed`, `submitter.completed`, `webhook.failed`, etc.

### API Keys
- Stored as encrypted configs
- SHA256 hashed access tokens
- Expiration support
- Usage analytics

---

## Frontend Architecture

### React SPA (ShakaPack)
```javascript
// Built with Create React App + React Redux Toolkit
// Webpack bundling
// Tailwind CSS styling
// TypeScript optional
```

### Key Frontend Components
- `Dashboard`: Admin dashboard
- `Templates`: Template builder
- `Submissions`: Submission listing
- `Settings`: Account settings
- `AccountConfig`: Multi-tenant config

### State Management
- **Redux Toolkit** for global state
- **React Context** for user/auth
- **RTK Query** for API calls

### Build Commands
```bash
npm run build           # Production build
npm run start           # Development server
npm run test            # Run tests
```

---

## Development Workflow

### Commands
```bash
bin/rails server         # Start development server
bin/rails db:migrate     # Run migrations
bin/rspec                # Run tests
bin/rubocop              # Code style checks
bin/bundle install       # Install gems
```

### Tests
```bash
rspec                     # Run all tests
rspec spec/models/        # Model tests
rspec spec/controllers/   # Controller tests
```

### Code Quality
- **Rubocop**: Ruby code style
- **Eslint**: JavaScript linting
- **ERBLint**: ERB syntax
- **Brakeman**: Security audit
- **SimpleCov**: Coverage reports

---

## Deployment Options

### Docker
```bash
docker run --name docuseal -p 3000:3000 -v.:/data docuseal/docuseal
```

### Docker Compose
```bash
curl https://raw.githubusercontent.com/docusealco/docuseal/master/docker-compose.yml > docker-compose.yml
sudo HOST=your-domain.com docker compose up
```

### Platforms
- **Heroku**: Official buildpack
- **Railway**: One-click deploy
- **Render**: Docker support
- **DigitalOcean**: App platform

### Environment Variables
```bash
DATABASE_URL=postgres://user:pass@host/db
SMTP_HOST=smtp.example.com
SMTP_PORT=587
API_KEY=your-api-key
SECRET_KEY_BASE=your-secret-key
```

---

## Code Style Guidelines

### Ruby
- **Rubocop** with Rails, RSpec, Performance plugins
- Max method length: 30 lines
- Max cyclomatic complexity: 15
- Snake_case for methods, PascalCase for classes
- Double-quoted strings only when needed

### JavaScript/TypeScript
- **ESLint** with standard + vue plugins
- Prettier for formatting
- Arrow functions preferred
- No `any` type without comment

### ERB Views
- Slim indentation
- No indentation inside conditionals
- Use locals sparingly
- Inline CSS in styles attribute

---

## Key Files Reference

### Entry Points
- `config/application.rb` - Rails app config
- `config/routes.rb` - All routes (150+)
- `Rakefile` - Task definitions
- `Gemfile` - Dependencies

### Core Config
- `config/database.yml` - DB connections
- `config/storage.yml` - File storage
- `config/environment` - ENV loading
- `config/puma.rb` - Server config

### Models (Key)
- `app/models/user.rb` - User with Devise
- `app/models/submission.rb` - Document submissions
- `app/models/template.rb` - Document templates
- `app/models/submitter.rb` - Individual signers
- `app/models/account.rb` - Multi-tenant accounts

### Controllers (Key)
- `app/controllers/submissions_controller.rb` - Main submission logic
- `app/controllers/templates_controller.rb` - Template management
- `app/controllers/api/submissions_controller.rb` - API endpoint

### Mailers
- `app/mailers/submitter_mailer.rb` - Submitter emails
- `app/mailers/user_mailer.rb` - User emails

---

## Third-Party Gems

### Core Rails
- `rails-i18n` - Multi-language support
- `turbo-rails` - Hotwire support
- `cancancan` - Authorization
- `devise` + `devise-two-factor` - Auth

### File Processing
- `hexapdf` - PDF generation/merging
- `ruby-vips` - Image processing
- `image_processing` - Image utilities
- `mini_magick` - Image manipulation

### Cloud Storage
- `aws-sdk-s3` - S3 storage
- `google-cloud-storage` - GCS
- `azure-blob` - Azure storage

### Database
- `pg` - PostgreSQL adapter
- `sqlite3` - SQLite (dev)
- `trilogy` - MySQL adapter

### Testing/Dev
- `rspec-rails` - Testing framework
- `capybara` + `cuprite` - Selenium-less browser
- `factory_bot_rails` - Test fixtures
- `web-console` - Dev tooling

### Background Jobs
- `sidekiq` - Async jobs
- `redis-client` - Redis adapter

---

## Common Development Tasks

### Adding a New Model
```ruby
# 1. Create migration
bin/rails generate model SubmissionEvent event_type:string account_id:bigint created_at:datetime

# 2. Create model file
# 3. Run migration
bin/rails db:migrate

# 4. Add controller
bin/rails generate controller SubmissionEvents

# 5. Add routes
# Edit config/routes.rb
```

### Adding a New Controller
```ruby
# 1. Generate
bin/rails generate controller Templates::Documents

# 2. Edit controller
# Define index action

# 3. Add routes
resources :templates do
  resources :documents, controller: 'templates_documents'
end
```

### Writing Tests
```ruby
# spec/models/submission_spec.rb
require 'rails_helper'

RSpec.describe Submission, type: :model do
  it 'has a valid name' do
    submission = create(:submission, name: 'Test')
    expect(submission.valid?).to be true
  end
end
```

---

## Troubleshooting Common Issues

### N+1 Query Issues
```ruby
# Use bullet gem or add eager loading
submissions.includes(:submitters).where(expire_at: ..Time.current)
```

### Database Locking
```ruby
# Use transactions for concurrent access
ActiveRecord::Base.transaction do
  # critical logic
end
```

### File Upload Issues
```bash
# Check ActiveStorage service config
RAILS_ENV=production rails active_storage:prepare
```

### Sidekiq Not Running
```bash
# Add to Procfile in Procfile
sidekiq: bundle exec sidekiq

# Run manually
bundle exec sidekiq
```

---

## Contributing Guidelines

### Code Reviews
- All PRs must pass CI checks
- Tests must be added for new features
- Rubocop compliance required
- Documentation for public APIs

### Security
- Report vulnerabilities to security@docuseal.com
- No GitHub issues for security bugs
- Use GitHub issues for non-security bugs only

### Documentation
- Update README for new features
- Add examples to code comments
- Document API endpoints

---

## License

**AGPLv3** with [Additional Terms](LICENSE_ADDITIONAL_TERMS)

Out of scope for bug bounty:
- CSRF vulnerabilities
- DNSSEC/CAA/CSP headers
- DNS/email security
- Rate limiting issues

Report security issues to: security@docuseal.com

---

## Related Projects

- [DocuSeal React](https://github.com/docusealco/docuseal-react)
- [DocuSeal Vue](https://github.com/docusealco/docuseal-vue)
- [DocuSeal Angular](https://github.com/docusealco/docuseal-angular)
- [DocuSeal DigitalOcean](https://github.com/docusealco/docuseal-digitalocean)
- [DocuSeal Render](https://github.com/docusealco/docuseal-render)

## Resources

- [Official Website](https://www.docuseal.com)
- [Demo](https://demo.docuseal.tech)
- [Cloud Sign Up](https://docuseal.com/sign_up)
- [Documentation](https://www.docuseal.com/docs)
- [Discord Community](https://discord.gg/qygYCDGck9)
- [Twitter](https://twitter.com/docusealco)

---

*Last updated: 2026-04-13*
