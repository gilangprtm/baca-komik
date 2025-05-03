# BacaKomik Mobile App Tasks

## Setup & Configuration

- [x] Initialize Flutter project with clean architecture
- [x] Set up project structure (core, data, presentation)
- [x] Configure Dio for API communication
- [ ] Update base URL in DioService to point to BacaKomik API
- [x] Configure token handling and authentication
- [x] Set up proper error handling
- [x] Implement logging and performance tracking

## Data Layer

### Models
- [x] Create Comic model
- [x] Create Chapter model
- [x] Create Page model
- [x] Create User model
- [x] Create Comment model
- [x] Create Bookmark model
- [x] Create Vote model
- [x] Create Genre, Author, Artist, Format models

### Repositories
- [x] Implement ComicRepository
  - [x] Get all comics with filtering and pagination
  - [x] Get comic details
  - [x] Get comic chapters
- [x] Implement ChapterRepository
  - [x] Get chapter details
  - [x] Get chapter pages
- [x] Implement UserRepository
  - [x] Login/logout functionality
  - [x] Get user profile
  - [x] Update user profile
- [x] Implement BookmarkRepository
  - [x] Add bookmark
  - [x] Remove bookmark
  - [x] Get user bookmarks
- [x] Implement VoteRepository
  - [x] Add vote
  - [x] Remove vote
- [x] Implement CommentRepository
  - [x] Get comments
  - [x] Post comment

### Services
- [x] Implement ComicService
- [x] Implement ChapterService
- [x] Implement UserService
- [x] Implement BookmarkService
- [x] Implement VoteService
- [x] Implement CommentService

## Presentation Layer

### State Management (Riverpod)
- [ ] Set up Riverpod providers
- [ ] Implement comic providers
- [ ] Implement chapter providers
- [ ] Implement user providers
- [ ] Implement bookmark providers
- [ ] Implement vote providers
- [ ] Implement comment providers

### Pages
- [ ] Create Splash screen
- [ ] Create Login/Register screens
- [ ] Create Home screen
  - [ ] Featured comics section
  - [ ] Popular comics section
  - [ ] Latest updates section
  - [ ] Genre filtering
- [ ] Create Comic Details screen
  - [ ] Comic information
  - [ ] Chapter list
  - [ ] Comments section
  - [ ] Bookmark and vote functionality
- [ ] Create Chapter Reader screen
  - [ ] Page navigation
  - [ ] Reading controls (zoom, page turn)
  - [ ] Comments section
  - [ ] Vote functionality
- [ ] Create Search screen
  - [ ] Search by title
  - [ ] Advanced filtering
- [ ] Create Bookmarks screen
- [ ] Create History screen
- [ ] Create Profile screen
  - [ ] User information
  - [ ] Settings

### Widgets
- [ ] Create ComicCard widget
- [ ] Create ChapterListItem widget
- [ ] Create CommentItem widget
- [ ] Create Loading indicators
- [ ] Create Error handling widgets
- [ ] Create Navigation components

## Features

### Authentication
- [ ] Implement login flow
- [ ] Implement registration flow
- [ ] Implement token refresh
- [ ] Implement secure token storage
- [ ] Implement logout functionality

### Comic Reading
- [ ] Implement comic browsing with infinite scroll
- [ ] Implement chapter reading with page navigation
- [ ] Implement reading progress tracking
- [ ] Implement zoom and pan functionality for pages
- [ ] Implement reading mode options (left-to-right, right-to-left)

### User Interactions
- [ ] Implement bookmarking functionality
- [ ] Implement voting functionality
- [ ] Implement commenting functionality
- [ ] Implement reading history tracking

### Offline Support
- [ ] Implement caching for recently viewed comics
- [ ] Implement offline reading for downloaded chapters
- [ ] Implement background downloading

## Testing
- [ ] Write unit tests for repositories
- [ ] Write unit tests for services
- [ ] Write widget tests for key UI components
- [ ] Write integration tests for main user flows

## Performance Optimization
- [ ] Optimize image loading and caching
- [ ] Implement lazy loading for lists
- [ ] Optimize memory usage during chapter reading
- [ ] Implement proper disposal of resources

## Deployment
- [ ] Configure app icons and splash screens
- [ ] Prepare app for release (Android & iOS)
- [ ] Set up CI/CD pipeline
- [ ] Implement analytics and crash reporting
