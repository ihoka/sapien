# Sapien - Product Strategy & Platform Plan

## Vision
A multi-platform social media management and automation tool built on Rails 8 with Hotwire, enabling users to schedule, post, and manage content across multiple social platforms from a single interface.

## Platform Integration Strategy

### Phase 1: Telegram (MVP) 🚀
**Start Date:** 2025-10-28
**Status:** Planning

**Why Telegram First:**
- ✅ Completely free API with no message charges
- ✅ Simple token-based authentication via @BotFather
- ✅ Generous rate limits for development and testing
- ✅ Supports both channels (broadcast) and groups
- ✅ Rich media support (photos, videos, documents, audio, stickers)
- ✅ Perfect for MVP validation without ongoing API costs
- ✅ Great for content creators and community management

**Telegram Capabilities to Support:**
- Post to channels (broadcast to unlimited subscribers)
- Post to groups (up to 200,000 members)
- Schedule posts
- Media uploads (images, videos, documents)
- Message editing and deletion
- Forum topics in groups
- Polls (up to 12 options)

### Phase 2: X (Twitter)
**Status:** Planned for future

**X API Details:**
- **Pricing:** Free tier (500 posts/month), Basic $200/month (3,000 posts/month)
- **Features:** Text posts, media uploads, polls, alt text, quote tweets, reply settings
- **API Version:** X API v2

**Integration Priority:** After Telegram MVP is stable and validated.

### Phase 3: WhatsApp Business
**Status:** Future consideration

**WhatsApp API Details:**
- **Pricing:** Per-message pricing (varies by region and message type)
  - Service messages: FREE (within 24-hour window)
  - Marketing messages: ~$0.025/message (US)
  - Utility messages: ~$0.004/message outside window (US)
- **Setup Complexity:** Requires Business Solution Provider (BSP)
- **Use Case:** Customer service, transactional messaging, 1-to-1 communication

**Integration Priority:** When customers specifically request WhatsApp integration.

### Future Platforms (Consideration)
- LinkedIn (professional networking)
- Facebook/Instagram (Meta platforms)
- Mastodon (federated social)
- Discord (community management)
- Bluesky (emerging platform)

## Technical Architecture

### Core Tech Stack
- **Framework:** Ruby on Rails 8.1.0
- **Ruby Version:** 3.4.5
- **UI Framework:** Hotwire (Turbo + Stimulus) - HTML over the wire
- **CSS Framework:** Tailwind CSS
- **Database:** SQLite3 (development), PostgreSQL (production consideration)
- **Background Jobs:** Solid Queue (database-backed)
- **Caching:** Solid Cache (database-backed)
- **Real-time:** Solid Cable (database-backed)
- **Deployment:** Kamal + Docker

### Architecture Principles
1. **Platform-Agnostic Design:** Core models support multiple platforms
2. **Adapter Pattern:** Each platform has its own adapter/service class
3. **Queue-Based:** All posting operations go through background jobs
4. **Extensible:** Easy to add new platforms without modifying core code
5. **HTML Over the Wire:** No separate frontend framework, Hotwire for interactivity

### Core Models (Draft)
- `User` - Application users
- `SocialAccount` - Platform accounts (Telegram, X, WhatsApp, etc.)
- `Post` - Scheduled or published posts
- `Media` - Uploaded media files (images, videos, documents)
- `PostSchedule` - Scheduling configuration
- `Platform` - Platform definitions and capabilities
- `PlatformAdapter` - Interface for platform-specific operations

### Service Layer
- `Platforms::Telegram::Client` - Telegram API client
- `Platforms::Telegram::PostService` - Post to Telegram
- `Platforms::Twitter::Client` - X API client (future)
- `Platforms::WhatsApp::Client` - WhatsApp API client (future)
- `PostSchedulerJob` - Background job for scheduled posts
- `MediaProcessorJob` - Process and optimize media files

## Business Model

### Initial Phase (Current)
**Self-Hosted / Personal Use**
- Run on personal machines/servers
- No subscription fees
- No payment processing
- Focus on feature development and validation

### Future Monetization
**Subscription-Based SaaS**
- **Payment Processor:** Stripe
- **Pricing Tiers:** TBD (based on features, platform access, post volume)
- **Free Tier:** Limited posts/month, basic features
- **Pro Tier:** Higher limits, advanced features, priority support
- **Enterprise Tier:** Custom limits, dedicated support, SLA

**Potential Revenue Streams:**
1. Monthly/annual subscriptions
2. Pay-per-post or pay-per-platform pricing
3. Advanced analytics and insights (premium feature)
4. Team collaboration features (premium)
5. White-label solutions (enterprise)

### Cost Considerations
- **Telegram:** $0/month (free API)
- **X Basic:** $200/month (when needed)
- **WhatsApp:** Variable per-message costs (when needed)
- **Infrastructure:** Hosting, database, storage
- **Stripe Fees:** 2.9% + $0.30 per transaction

## Feature Roadmap

### MVP (Phase 1) - Telegram Integration
- [ ] User authentication and registration
- [ ] Connect Telegram accounts (bot token)
- [ ] Create and schedule posts
- [ ] Upload and manage media
- [ ] Post immediately or schedule for later
- [ ] View post history and status
- [ ] Basic analytics (posts sent, scheduled)
- [ ] Responsive UI with Tailwind CSS

### Phase 2 - Multi-Platform Foundation
- [ ] Platform abstraction layer
- [ ] X (Twitter) integration
- [ ] Unified post composer (works for all platforms)
- [ ] Platform-specific features (polls, threads, etc.)
- [ ] Advanced scheduling (recurring posts, time zones)

### Phase 3 - Advanced Features
- [ ] Content calendar view
- [ ] Draft management
- [ ] Approval workflows (team feature)
- [ ] Analytics dashboard
- [ ] Post performance tracking
- [ ] Media library management

### Phase 4 - Monetization
- [ ] Stripe integration
- [ ] Subscription plans
- [ ] Usage tracking and limits
- [ ] Billing dashboard
- [ ] Invoice generation

### Phase 5 - Scale & Growth
- [ ] Team collaboration features
- [ ] Role-based access control
- [ ] API for third-party integrations
- [ ] Webhook support
- [ ] Advanced analytics and reporting
- [ ] WhatsApp Business integration

## Development Principles

### Rails 8 / Hotwire First
- Embrace Rails conventions and defaults
- Use Turbo Frames for partial page updates
- Use Turbo Streams for real-time updates
- Minimal JavaScript via Stimulus controllers
- Progressive enhancement

### Testing Strategy
- Unit tests for all models and services
- Controller tests for all endpoints
- System tests for critical user flows
- Background job tests
- API integration tests (use VCR for external APIs)

### Security & Compliance
- Secure API token storage (encrypted credentials)
- Rate limiting for API calls
- Data encryption at rest and in transit
- GDPR compliance (data export, deletion)
- Regular security audits (Brakeman, Bundler Audit)

### Performance
- Database-backed queuing (Solid Queue)
- Background processing for all API calls
- Efficient database queries (avoid N+1)
- Media optimization and CDN delivery (future)
- Caching strategies for common queries

## Success Metrics

### MVP Success Criteria
- [ ] Successfully post to Telegram channels
- [ ] Schedule posts for future delivery
- [ ] Handle media uploads reliably
- [ ] Zero downtime for scheduled posts
- [ ] Personal use validates core functionality

### Growth Metrics (Future)
- Monthly Active Users (MAU)
- Posts sent per month
- Platform adoption rate
- User retention rate
- Customer acquisition cost (CAC)
- Lifetime value (LTV)
- Net Promoter Score (NPS)

## Timeline

### Q1 2025 (Current)
- ✅ Research platform APIs (Telegram, X, WhatsApp)
- ✅ Define product strategy and architecture
- [ ] Build Telegram integration MVP
- [ ] Test with personal accounts

### Q2 2025
- [ ] Refine Telegram features based on usage
- [ ] Add X (Twitter) integration
- [ ] Implement subscription model foundation

### Q3-Q4 2025
- [ ] Launch public beta
- [ ] Add more platforms based on demand
- [ ] Implement analytics and advanced features

## Notes

**Last Updated:** 2025-10-28
**Document Owner:** Product Team
**Review Cadence:** Monthly or as needed

---

This strategy document should be updated as the product evolves and new insights are gained.
