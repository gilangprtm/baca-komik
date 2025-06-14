# BacaKomik Project Tasks

## Database Setup

- [x] Create enum types (country_id, etc.)
- [x] Create master tables (mKomik, mChapter, mUser, etc.)
- [x] Create transaction/relationship tables (trChapter, trComments, etc.)
- [x] Set up appropriate indexes for performance
- [x] Implement row-level security (RLS) policies
- [x] Create database functions and triggers where needed

## Next.js Backend Setup

- [x] Initialize Next.js project with TypeScript
- [x] Set up Supabase client configuration
- [x] Create database type definitions
- [x] Implement API routes for comic data
  - [x] GET /api/comics - List comics with pagination
  - [x] GET /api/comics/:id - Get comic details
  - [x] GET /api/comics/:id/chapters - List chapters for a comic
  - [x] GET /api/chapters/:id - Get chapter details
  - [x] GET /api/chapters/:id/pages - Get pages for a chapter
- [x] Implement API routes for user interactions
  - [x] POST /api/bookmarks - Add bookmark
  - [x] DELETE /api/bookmarks/:id - Remove bookmark
  - [x] GET /api/bookmarks - Get user bookmarks
  - [x] POST /api/votes - Add vote
  - [x] DELETE /api/votes/:id - Remove vote
  - [x] POST /api/comments - Add comment
  - [x] GET /api/comments/:id - Get comments
- [x] Create view counting mechanism
- [x] Implement authentication middleware

## Admin Dashboard

- [x] Create admin layout and navigation
- [x] Implement comic management UI
  - [x] Comic list view with filtering/sorting
  - [x] Comic creation/edit form
  - [x] Chapter management interface
  - [x] Page upload and management
- [x] Implement metadata management
  - [x] Artists management
  - [x] Authors management
  - [x] Genres management
  - [x] Formats management
  - [x] Optimized UI with tab-based interface
  - [x] Search functionality for each metadata type
  - [x] Lazy loading data on tab selection
  - [x] Optimized loading for selected items
  - [x] Visual loading indicators for better UX
  - [x] Caching to avoid redundant fetches
- [x] Create featured comics management
  - [x] Recommended comics interface
  - [x] Popular comics interface
  - [x] Tabbed interface for easier management
  - [x] Search functionality to find comics quickly
  - [x] Period type selection for popular comics (daily, weekly, monthly, all-time)
  - [x] Responsive grid layout for better UX
- [ ] Build analytics dashboard
  - [ ] View count statistics
  - [ ] User engagement metrics
  - [ ] Popular content reports

## Deployment

- [ ] Set up CI/CD pipeline
- [ ] Configure production environment
- [ ] Deploy backend and admin dashboard
- [ ] Documentation for maintenance
