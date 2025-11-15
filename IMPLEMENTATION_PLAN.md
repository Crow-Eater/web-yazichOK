# Implementation Plan for yazichOK Language Learning Platform

This document outlines the step-by-step implementation plan based on `plan.md`.

## Overview

We'll implement features in phases, starting with foundational infrastructure, then building features incrementally with mock data. Each phase delivers working, testable functionality.

---

## Phase 0: Foundation & Infrastructure (MUST DO FIRST)

### Step 0.1: Add Required Dependencies
**File**: `pubspec.yaml`

Add packages:
```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  equatable: ^2.0.5             # Immutable state classes
  go_router: ^12.0.0            # Routing with deep links
  dio: ^5.4.0                   # HTTP client (for future real APIs)
  just_audio: ^0.9.36           # Audio playback (web support)
  shared_preferences: ^2.2.2    # Local storage
  lottie: ^2.7.0                # Animations

dev_dependencies:
  freezed: ^2.4.5               # Code generation for state classes
  build_runner: ^2.4.6          # Code generation
  json_serializable: ^6.7.1     # JSON serialization
  mocktail: ^1.0.1              # Mocking for tests
```

**Action**: Run `flutter pub get` after adding dependencies.

---

### Step 0.2: Create Project Structure
**Create directories**:
```
lib/
├── core/
│   ├── di/                    # Dependency injection
│   ├── routing/               # Router configuration
│   └── theme/                 # App theme
├── data/
│   ├── models/                # Data models
│   ├── repositories/          # Repository implementations
│   └── mock_data/             # Mock data files
├── domain/
│   ├── repositories/          # Repository interfaces
│   └── managers/              # Manager interfaces (Auth, Audio, etc.)
├── presentation/
│   ├── main/                  # Main screen
│   ├── flashcards/           # FlashCards module
│   ├── learn/                # Learn module
│   ├── auth/                 # Authentication module
│   ├── speaking/             # Speech assessment module
│   └── articles/             # Articles module
└── main.dart
```

**Why this order**: We need structure before writing code.

---

### Step 0.3: Setup Routing with go_router
**Files to create**:
- `lib/core/routing/app_router.dart`
- `lib/core/routing/route_names.dart`

**Implementation**:
1. Define route paths as constants in `route_names.dart`
2. Configure `GoRouter` with all routes from plan.md:
   - `/` → MainScreen
   - `/flashcards` → FlashCardsScreen
   - `/flashcards/add-word` → AddNewWordScreen
   - `/flashcards/add-group` → AddNewGroupScreen
   - `/flashcards/group/:groupId` → MemoriseWordsScreen
   - `/learn` → LearnScreen
   - `/learn/grammar-topics` → GrammarTopicsScreen
   - `/learn/test/:topicId` → TestScreen
   - `/learn/listening` → ListeningPracticeScreen
   - `/auth/signin` → SignInScreen
   - `/auth/signup` → SignUpScreen
   - `/speaking/topics` → SpeakingTopicsScreen
   - `/speaking/recording` → RecordingScreen
   - `/speaking/assessment` → SpeakingAssessmentScreen
   - `/speaking/results` → SpeakingResultsScreen
   - `/articles` → ArticlesPreviewScreen
   - `/articles/:articleId` → ArticleScreen
   - `/articles/:articleId/analysis` → ArticleAnalysisScreen
3. Add redirect logic for authentication (if not authenticated → `/auth/signin`)
4. Update `main.dart` to use `MaterialApp.router` with the configured router

**Why this order**: Routing is fundamental—needed before creating any screens.

---

### Step 0.4: Create Data Models
**Files to create** in `lib/data/models/`:
- `word_group.dart` - FlashCard groups
- `flash_card.dart` - Individual flashcards
- `grammar_topic.dart` - Grammar topics
- `question.dart` - Test questions
- `answer_option.dart` - Answer options
- `audio_record.dart` - Audio items
- `user.dart` - User model
- `speaking_topic.dart` - Speaking topics
- `assessment_result.dart` - Assessment results
- `article.dart` - Article model
- `article_analysis.dart` - Article analysis data
- `vocabulary_item.dart` - Vocabulary items
- `grammar_point.dart` - Grammar points

**Implementation**:
- Use `equatable` for value equality
- Add `toJson`/`fromJson` methods for serialization
- Keep models simple (data classes only, no business logic)

**Why this order**: Models are used everywhere—define them early.

---

### Step 0.5: Create Repository/Manager Interfaces
**Files to create** in `lib/domain/`:

**repositories/**:
- `network_repository.dart` - Interface for network calls

**managers/**:
- `auth_manager.dart` - Authentication interface
- `audio_manager.dart` - Audio playback interface
- `recorder_manager.dart` - Recording interface (speech)

**Implementation example** (`network_repository.dart`):
```dart
abstract class NetworkRepository {
  Future<List<WordGroup>> getFlashcardGroups();
  Future<void> addFlashcardGroup(String name);
  Future<void> addWord(String groupId, FlashCard word);
  Future<List<FlashCard>> getWordsForGroup(String groupId);
  Future<List<GrammarTopic>> getGrammarTopics();
  Future<List<Question>> getQuestions(String topicId);
  Future<List<AudioRecord>> getAudioRecords();
  Future<List<SpeakingTopic>> getSpeakingTopics();
  Future<AssessmentResult> assessRecording(String audioBlob, String topicId);
  Future<List<Article>> getArticles();
  Future<Article> getArticle(String id);
  Future<ArticleAnalysis> analyzeArticle(String id);
}
```

**Why this order**: Interfaces define contracts before implementations.

---

### Step 0.6: Create Mock Implementations
**Files to create** in `lib/data/repositories/`:
- `mock_network_repository.dart`

**Files to create** in `lib/data/mock_data/`:
- `mock_flashcard_data.dart`
- `mock_grammar_data.dart`
- `mock_audio_data.dart`
- `mock_auth_data.dart`
- `mock_speaking_data.dart`
- `mock_articles_data.dart`

**Implementation**:
- Use the mock data examples from plan.md (lines 792-932)
- Store data in-memory (use `List` and `Map`)
- Implement all interface methods with mock behavior
- Add artificial delays (`Future.delayed`) to simulate network calls

**Why this order**: Mock data allows feature development without backend.

---

### Step 0.7: Setup Dependency Injection
**File**: `lib/core/di/service_locator.dart`

**Implementation**:
- Create a simple service locator or use `provider` package
- Register all repositories and managers
- Use factories to create instances
- Example:
```dart
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final NetworkRepository networkRepository;
  late final AuthManager authManager;
  late final AudioManager audioManager;

  void setup() {
    networkRepository = MockNetworkRepository();
    authManager = MockAuthManager();
    audioManager = LocalAudioManager();
  }
}
```

**Why this order**: DI setup needed before creating Cubits.

---

### Step 0.8: Create App Theme
**File**: `lib/core/theme/app_theme.dart`

**Implementation**:
- Define color scheme matching screenshots (purple accent for FlashCards)
- Typography settings
- Material 3 theme configuration
- Dark mode support (optional)

**Why this order**: Consistent theming from the start.

---

## Phase 1: Authentication & Main Screen (Build User Foundation)

### Step 1.1: Implement Authentication State Management
**Files to create**:
- `lib/presentation/auth/cubit/auth_cubit.dart`
- `lib/presentation/auth/cubit/auth_state.dart`

**Implementation**:
- States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`
- Methods: `signIn(email, password)`, `signUp(email, password)`, `signOut()`, `checkSession()`
- Use `AuthManager` interface
- Emit appropriate states

**Tests to write**:
- `test/presentation/auth/cubit/auth_cubit_test.dart`

---

### Step 1.2: Implement Sign In Screen
**Reference**: `screen_shots/Sign in.png`, plan.md lines 407-436

**Files to create**:
- `lib/presentation/auth/screens/sign_in_screen.dart`
- `lib/presentation/auth/widgets/email_field.dart`
- `lib/presentation/auth/widgets/password_field.dart`

**Implementation**:
1. Email field with validation (basic email format check)
2. Password field with secure entry and optional show/hide toggle
3. Sign In button (disabled until both fields valid)
4. Navigation text to Sign Up screen
5. Error message display
6. Use `BlocConsumer<AuthCubit, AuthState>` to handle navigation on success

**Tests to write**:
- `test/presentation/auth/screens/sign_in_screen_test.dart`

---

### Step 1.3: Implement Sign Up Screen
**Reference**: `screen_shots/Sign up.png`, plan.md lines 440-466

**Files to create**:
- `lib/presentation/auth/screens/sign_up_screen.dart`

**Implementation**:
1. Email field (reuse widget from 1.2)
2. Password field (reuse widget)
3. Repeat password field
4. Validation: password must match repeat password
5. Sign Up button (disabled until all validation passes)
6. Navigation text to Sign In screen
7. Handle "email already exists" error from mock

**Tests to write**:
- `test/presentation/auth/screens/sign_up_screen_test.dart`

---

### Step 1.4: Implement Main Screen
**Reference**: `screen_shots/Main screen.png`, plan.md lines 144-178

**Files to create**:
- `lib/presentation/main/screens/main_screen.dart`
- `lib/presentation/main/cubit/main_cubit.dart`
- `lib/presentation/main/cubit/main_state.dart`
- `lib/presentation/main/widgets/feature_card.dart`

**Implementation**:
1. Create MainCubit to manage state
2. Layout: Feature cards for each module
3. **Purple UI element** for FlashCards (matching screenshot)
4. Cards for: Learn, Speaking, Articles
5. Each card navigates to corresponding route
6. App bar with user profile/logout option
7. Responsive layout for web

**Tests to write**:
- `test/presentation/main/screens/main_screen_test.dart`

---

## Phase 2: Flash Cards Module (First Complete Feature)

### Step 2.1: Implement FlashCards State Management
**Files to create**:
- `lib/presentation/flashcards/cubit/flashcards_cubit.dart`
- `lib/presentation/flashcards/cubit/flashcards_state.dart`

**Implementation**:
- States: `FlashCardsInitial`, `FlashCardsLoading`, `FlashCardsLoaded`, `FlashCardsError`
- Methods: `loadGroups()`, `addGroup(name)`, `addWord(groupId, word)`, `deleteGroup(id)`, `deleteWord(id)`
- Use `NetworkRepository` to fetch/store data

**Tests to write**:
- `test/presentation/flashcards/cubit/flashcards_cubit_test.dart`

---

### Step 2.2: Implement FlashCards Main Screen
**Reference**: plan.md lines 188-201

**Files to create**:
- `lib/presentation/flashcards/screens/flashcards_screen.dart`
- `lib/presentation/flashcards/widgets/group_list_item.dart`

**Implementation**:
1. AppBar with leading IconButton (plus icon) → navigates to Add New Word
2. FloatingActionButton (bottom right, folder icon) → navigates to Add New Group
3. List of word groups using `BlocBuilder<FlashCardsCubit, FlashCardsState>`
4. Each group shows: name, word count
5. Tapping group → navigate to `/flashcards/group/:groupId`
6. Empty state when no groups exist

**Tests to write**:
- `test/presentation/flashcards/screens/flashcards_screen_test.dart`

---

### Step 2.3: Implement Add New Word Screen
**Reference**: `screen_shots/Add word.png`, plan.md lines 208-223

**Files to create**:
- `lib/presentation/flashcards/screens/add_new_word_screen.dart`

**Implementation**:
1. Form with fields:
   - Word (required, TextField)
   - Transcription (optional, TextField)
   - Translation (required, TextField)
   - Group selector (DropdownButton with existing groups)
2. "Create new group" option in dropdown → navigate to Add New Group
3. Save button:
   - Validates required fields
   - Calls `FlashCardsCubit.addWord(groupId, word)`
   - Shows success message
   - Navigates back
4. Form validation and error display

**Tests to write**:
- `test/presentation/flashcards/screens/add_new_word_screen_test.dart`

---

### Step 2.4: Implement Add New Group Screen
**Reference**: plan.md lines 225-229

**Files to create**:
- `lib/presentation/flashcards/screens/add_new_group_screen.dart`

**Implementation**:
1. Single TextField for group name
2. Save button (disabled if empty)
3. Calls `FlashCardsCubit.addGroup(name)`
4. Navigates back to FlashCards screen on success

**Tests to write**:
- `test/presentation/flashcards/screens/add_new_group_screen_test.dart`

---

### Step 2.5: Implement Memorise Words State Management
**Files to create**:
- `lib/presentation/flashcards/cubit/memorise_cubit.dart`
- `lib/presentation/flashcards/cubit/memorise_state.dart`

**Implementation**:
- States: `MemoriseInitial`, `MemoriseInProgress`, `MemoriseCompleted`
- Properties in `MemoriseInProgress`: currentWord, currentIndex, knownCount, unknownCount, isTranslationRevealed
- Methods: `loadGroup(groupId)`, `revealTranslation()`, `markKnown()`, `markUnknown()`, `reset()`
- Track statistics for completion

**Tests to write**:
- `test/presentation/flashcards/cubit/memorise_cubit_test.dart`

---

### Step 2.6: Implement Memorise Words Screen
**Reference**: `screen_shots/Word card.png`, plan.md lines 231-267

**Files to create**:
- `lib/presentation/flashcards/screens/memorise_words_screen.dart`
- `lib/presentation/flashcards/widgets/flashcard_widget.dart`
- `lib/presentation/flashcards/widgets/statistics_card.dart`

**Implementation**:
1. FlashCard display:
   - Word (large text)
   - Transcription (smaller text)
   - "Reveal Translation" button (initially)
   - Translation (shown after reveal)
2. Bottom row with two buttons:
   - "Don't Know" (red-ish color)
   - "Know" (green-ish color)
3. Both buttons advance to next word
4. Statistics screen when all words completed:
   - Count known
   - Count unknown
   - Restart button
   - Back to groups button
5. Handle empty group (no words)

**Tests to write**:
- `test/presentation/flashcards/screens/memorise_words_screen_test.dart`

---

## Phase 3: Learn Module (Grammar Tests + Listening)

### Step 3.1: Implement Learn Screen
**Reference**: `screen_shots/ThemeChoice.png`, plan.md lines 281-311

**Files to create**:
- `lib/presentation/learn/screens/learn_screen.dart`
- `lib/presentation/learn/widgets/learning_option_card.dart`

**Implementation**:
1. List/Grid of learning options:
   - **Tests** card → navigate to `/learn/grammar-topics`
   - **Listening Practice** card → navigate to `/learn/listening`
2. Each card shows: icon, title, description
3. Responsive layout matching screenshot
4. Tappable cards with visual feedback

**Tests to write**:
- `test/presentation/learn/screens/learn_screen_test.dart`

---

### Step 3.2: Implement Grammar Topics State Management
**Files to create**:
- `lib/presentation/learn/cubit/grammar_topics_cubit.dart`
- `lib/presentation/learn/cubit/grammar_topics_state.dart`

**Implementation**:
- States: `GrammarTopicsInitial`, `GrammarTopicsLoading`, `GrammarTopicsLoaded`, `GrammarTopicsError`
- Method: `loadTopics()`
- Use `NetworkRepository.getGrammarTopics()`

---

### Step 3.3: Implement Grammar Topics Screen
**Reference**: plan.md lines 313-318

**Files to create**:
- `lib/presentation/learn/screens/grammar_topics_screen.dart`
- `lib/presentation/learn/widgets/topic_list_item.dart`

**Implementation**:
1. List of grammar topics from mock data
2. Each item shows: topic title, description, question count
3. Tapping navigates to `/learn/test/:topicId`
4. Loading and error states

**Tests to write**:
- `test/presentation/learn/screens/grammar_topics_screen_test.dart`

---

### Step 3.4: Implement Test State Management
**Files to create**:
- `lib/presentation/learn/cubit/test_cubit.dart`
- `lib/presentation/learn/cubit/test_state.dart`

**Implementation**:
- States: `TestInitial`, `TestLoading`, `TestQuestionLoaded`, `TestResultShown`, `TestCompleted`
- Properties: currentQuestion, selectedOptionIndex, correctAnswersCount, totalQuestions
- Methods: `loadTopic(topicId)`, `selectOption(index)`, `checkAnswer()`, `continueToNext()`, `reset()`
- Logic: Check answer, track statistics, advance to next question

**Tests to write**:
- `test/presentation/learn/cubit/test_cubit_test.dart`

---

### Step 3.5: Implement Test Screen
**Reference**: `screen_shots/Test.png`, plan.md lines 320-363

**Files to create**:
- `lib/presentation/learn/screens/test_screen.dart`
- `lib/presentation/learn/widgets/question_card.dart`
- `lib/presentation/learn/widgets/result_card.dart`
- `lib/presentation/learn/widgets/summary_card.dart`

**Implementation**:
1. **Question Card**:
   - Question text
   - Radio buttons for options
   - Check button (disabled until option selected)
2. **Result Card** (shown after Check):
   - Correct/Incorrect indicator
   - Correct answer display (if wrong)
   - Explanation (optional)
   - Continue button
3. **Flow**:
   - User selects option → Check enabled
   - User taps Check → Result shown
   - User taps Continue → Next question OR summary
4. **Summary Card** (all questions done):
   - Correct count
   - Incorrect count
   - Percentage
   - Retake button
   - Back to topics button

**Tests to write**:
- `test/presentation/learn/screens/test_screen_test.dart`

---

### Step 3.6: Implement Audio Manager
**Files to create**:
- `lib/domain/managers/audio_manager.dart` (interface)
- `lib/data/managers/local_audio_manager.dart` (implementation)

**Implementation**:
- Interface methods: `load(AudioRecord)`, `play()`, `pause()`, `seek(Duration)`, `seekForward(seconds)`, `seekBackward(seconds)`, `dispose()`
- Streams: `positionStream`, `durationStream`, `playbackStateStream`
- Use `just_audio` package for implementation
- Load from local assets initially

---

### Step 3.7: Implement Listening Practice State Management
**Files to create**:
- `lib/presentation/learn/cubit/listening_cubit.dart`
- `lib/presentation/learn/cubit/listening_state.dart`

**Implementation**:
- States: `ListeningInitial`, `ListeningLoaded`, `ListeningPlaying`, `ListeningPaused`, `ListeningError`
- Properties: audioRecords, selectedRecord, position, duration, isPlaying
- Methods: `loadRecords()`, `selectRecord(id)`, `play()`, `pause()`, `seekBy(seconds)`
- Use `AudioManager` for playback control
- Listen to position/duration streams

**Tests to write**:
- `test/presentation/learn/cubit/listening_cubit_test.dart`

---

### Step 3.8: Implement Listening Practice Screen
**Reference**: `screen_shots/Audition.png`, plan.md lines 368-401

**Files to create**:
- `lib/presentation/learn/screens/listening_practice_screen.dart`
- `lib/presentation/learn/widgets/audio_player_card.dart`
- `lib/presentation/learn/widgets/audio_record_list.dart`

**Implementation**:
1. **Audio Player Card** (top):
   - Selected audio title
   - Play/Pause button (toggle based on state)
   - Seek backward button (-10s)
   - Seek forward button (+10s)
   - Current time / Total duration display
   - Progress bar (optional but recommended)
2. **Audio Records List** (bottom):
   - Scrollable list of audio items
   - Each item: title, duration
   - Highlight selected item
   - Tapping selects and loads audio
3. Auto-select first audio on load
4. Real-time position updates

**Audio assets to add**:
- Add sample MP3 files to `assets/audio/` directory
- Update `pubspec.yaml` to include assets

**Tests to write**:
- `test/presentation/learn/screens/listening_practice_screen_test.dart`

---

## Phase 4: Speech Assessment Module

### Step 4.1: Implement Recorder Manager
**Files to create**:
- `lib/domain/managers/recorder_manager.dart` (interface)
- `lib/data/managers/web_recorder_manager.dart` (web implementation)

**Implementation**:
- Interface methods: `startRecording()`, `stopRecording()`, `dispose()`
- Returns: audio blob/URL suitable for web
- Use browser-compatible recording package or Web Audio API via `flutter_web_plugins`
- Handle permissions

---

### Step 4.2: Implement Speech State Management
**Files to create**:
- `lib/presentation/speaking/cubit/speech_cubit.dart`
- `lib/presentation/speaking/cubit/speech_state.dart`

**Implementation**:
- States: `SpeechInitial`, `SpeechTopicsLoaded`, `SpeechRecordingIdle`, `SpeechRecording`, `SpeechRecordingStopped`, `SpeechAssessmentProcessing`, `SpeechAssessmentCompleted`, `SpeechResultsLoaded`, `SpeechError`
- Methods: `loadTopics()`, `selectTopic(id)`, `startRecording()`, `stopRecording()`, `submitRecording()`, `loadAssessmentResults()`, `loadResultsHistory()`
- Use `RecorderManager` and `NetworkRepository`

**Tests to write**:
- `test/presentation/speaking/cubit/speech_cubit_test.dart`

---

### Step 4.3: Implement Speaking Topics Screen
**Reference**: `screen_shots/Chat.png`, plan.md lines 474-503

**Files to create**:
- `lib/presentation/speaking/screens/speaking_topics_screen.dart`
- `lib/presentation/speaking/widgets/topic_card.dart`

**Implementation**:
1. Chat-like interface or card list
2. Each topic shows:
   - Title/question
   - Description
   - Difficulty level
   - Time limit
3. Tapping topic navigates to `/speaking/recording` with topic ID
4. Load topics from `SpeechCubit`

**Tests to write**:
- `test/presentation/speaking/screens/speaking_topics_screen_test.dart`

---

### Step 4.4: Implement Recording Screen
**Reference**: plan.md lines 505-547

**Files to create**:
- `lib/presentation/speaking/screens/recording_screen.dart`
- `lib/presentation/speaking/widgets/recording_controls.dart`

**Implementation**:
1. Topic display at top
2. Large record button (circular)
3. Recording indicator with animation (pulsing effect)
4. Timer display (elapsed time)
5. Stop button during recording
6. After stopping:
   - Re-record button
   - Submit button
7. Recording flow:
   - Tap record → start recording → show timer
   - Tap stop → recording stopped → show submit/re-record
   - Tap submit → navigate to assessment screen
8. Use `RecorderManager` for actual recording

**Tests to write**:
- `test/presentation/speaking/screens/recording_screen_test.dart`

---

### Step 4.5: Implement Speaking Assessment Screen
**Reference**: `screen_shots/Assesment.png`, plan.md lines 549-599

**Files to create**:
- `lib/presentation/speaking/screens/speaking_assessment_screen.dart`
- `lib/presentation/speaking/widgets/assessment_results_card.dart`

**Implementation**:
1. Processing state (loading indicator)
2. Results display:
   - Overall score
   - Breakdown: Pronunciation, Fluency, Accuracy scores
   - Visual indicators (progress bars, gauges)
   - Feedback text
3. Action buttons:
   - View detailed results → navigate to `/speaking/results`
   - Try again → navigate back to `/speaking/recording`
   - Continue → navigate to topics or main
4. Mock assessment generates random scores initially

**Tests to write**:
- `test/presentation/speaking/screens/speaking_assessment_screen_test.dart`

---

### Step 4.6: Implement Speaking Results Screen
**Reference**: `screen_shots/Speaking results.png`, plan.md lines 601-640

**Files to create**:
- `lib/presentation/speaking/screens/speaking_results_screen.dart`
- `lib/presentation/speaking/widgets/results_history_item.dart`
- `lib/presentation/speaking/widgets/statistics_section.dart`

**Implementation**:
1. Results summary at top:
   - Total attempts
   - Average score
   - Progress indicator
2. History list:
   - Date/time
   - Topic
   - Score
   - Tapping shows detailed assessment
3. Statistics section:
   - Progress over time (chart optional for MVP)
   - Strengths/weaknesses
4. Action button: Start new practice
5. Load history from mock data

**Tests to write**:
- `test/presentation/speaking/screens/speaking_results_screen_test.dart`

---

## Phase 5: Articles Module

### Step 5.1: Implement Articles State Management
**Files to create**:
- `lib/presentation/articles/cubit/articles_cubit.dart`
- `lib/presentation/articles/cubit/articles_state.dart`

**Implementation**:
- States: `ArticlesInitial`, `ArticlesLoading`, `ArticlesLoaded`, `ArticleLoading`, `ArticleLoaded`, `ArticleAnalysisProcessing`, `ArticleAnalysisCompleted`, `ArticlesError`
- Methods: `loadArticles()`, `loadArticle(id)`, `analyzeArticle(id)`, `bookmarkArticle(id)` (optional)
- Use `NetworkRepository`

**Tests to write**:
- `test/presentation/articles/cubit/articles_cubit_test.dart`

---

### Step 5.2: Implement Articles Preview Screen
**Reference**: `screen_shots/Articles list.png`, plan.md lines 645-683

**Files to create**:
- `lib/presentation/articles/screens/articles_preview_screen.dart`
- `lib/presentation/articles/widgets/article_card.dart`

**Implementation**:
1. Header with title
2. Scrollable list of articles
3. Each article card:
   - Title
   - Excerpt/preview
   - Reading time
   - Difficulty level
   - Published date (optional)
4. Tapping article → navigate to `/articles/:articleId`
5. Empty state if no articles
6. Pull-to-refresh (optional for web)

**Tests to write**:
- `test/presentation/articles/screens/articles_preview_screen_test.dart`

---

### Step 5.3: Implement Article Screen
**Reference**: `screen_shots/Article.png`, plan.md lines 685-724

**Files to create**:
- `lib/presentation/articles/screens/article_screen.dart`
- `lib/presentation/articles/widgets/article_content.dart`

**Implementation**:
1. Article header:
   - Title (large)
   - Author, date
   - Reading time
2. Scrollable article content:
   - Paragraphs with proper spacing
   - Text formatting (bold, italic if in data)
3. Bottom action button:
   - "Analyze Article" → navigate to `/articles/:articleId/analysis`
4. Optional: Bookmark, Share buttons
5. Back button
6. Load article by ID from `ArticlesCubit`

**Tests to write**:
- `test/presentation/articles/screens/article_screen_test.dart`

---

### Step 5.4: Implement Article Analysis Screen
**Reference**: plan.md lines 726-778

**Files to create**:
- `lib/presentation/articles/screens/article_analysis_screen.dart`
- `lib/presentation/articles/widgets/vocabulary_list.dart`
- `lib/presentation/articles/widgets/grammar_points_list.dart`
- `lib/presentation/articles/widgets/analysis_summary.dart`

**Implementation**:
1. Analysis header
2. Processing state (loading)
3. Results sections:
   - **Vocabulary Analysis**:
     - List of key words
     - Definitions/translations
     - Difficulty indicators
   - **Grammar Points**:
     - Highlighted structures
     - Explanations with examples
   - **Summary**:
     - Article summary
     - Key points
4. Action buttons:
   - Back to article
   - Export (optional)
5. Mock analysis: extract words, identify grammar patterns

**Tests to write**:
- `test/presentation/articles/screens/article_analysis_screen_test.dart`

---

## Phase 6: Polish & Integration

### Step 6.1: Add Navigation Bar/Drawer
**Implementation**:
1. Bottom navigation bar or side drawer
2. Items:
   - Main/Home
   - FlashCards
   - Learn
   - Speaking
   - Articles
3. Highlight current section
4. Responsive for web

---

### Step 6.2: Add Loading States & Error Handling
**Implementation**:
1. Consistent loading indicators across all screens
2. Error screens with retry functionality
3. Empty states with CTAs
4. Network error handling
5. User-friendly error messages

---

### Step 6.3: Add Animations & Transitions
**Implementation**:
1. Page transition animations
2. Lottie animations (if applicable)
3. Card flip animations (for flashcards)
4. Button press feedback
5. Smooth list animations

---

### Step 6.4: Responsive Web Layout
**Implementation**:
1. Breakpoints for mobile, tablet, desktop
2. Centered content on wide screens
3. Appropriate padding and margins
4. Touch and mouse interaction support
5. Keyboard navigation

---

### Step 6.5: Accessibility Improvements
**Implementation**:
1. Semantic labels for screen readers
2. Sufficient color contrast
3. Focus indicators
4. Text scaling support
5. Keyboard navigation

---

### Step 6.6: Comprehensive Testing
**Implementation**:
1. Unit tests for all Cubits (aim for 80%+ coverage)
2. Widget tests for all screens
3. Integration tests for critical flows:
   - Sign in → Main → FlashCards → Memorise
   - Grammar test complete flow
   - Article read and analysis
4. Run `flutter test --coverage`
5. Fix any failing tests

---

### Step 6.7: Documentation & Code Quality
**Implementation**:
1. Add inline documentation for complex logic
2. Run `flutter analyze` and fix all issues
3. Format code with `flutter format`
4. Update README.md with:
   - Setup instructions
   - Feature list
   - Screenshots
5. Add architecture diagram (optional)

---

## Testing Strategy (Throughout Development)

For each feature:
1. **Unit Tests**: Test Cubits in isolation with mocked dependencies
2. **Widget Tests**: Test UI components and user interactions
3. **Integration Tests**: Test complete user flows (after Phase 6)

Use `mocktail` for mocking repositories and managers.

---

## Definition of Done (Each Feature)

A feature is complete when:
- [ ] Implementation matches design screenshots
- [ ] All acceptance criteria from plan.md are met
- [ ] Unit tests written and passing
- [ ] Widget tests written and passing
- [ ] No lint errors (`flutter analyze`)
- [ ] Code formatted (`flutter format`)
- [ ] Integrated with router and navigation
- [ ] Error states handled
- [ ] Loading states displayed
- [ ] Manually tested in browser

---

## Estimated Effort

**Phase 0**: Foundation (2-3 days)
**Phase 1**: Auth + Main (2-3 days)
**Phase 2**: FlashCards (3-4 days)
**Phase 3**: Learn Module (4-5 days)
**Phase 4**: Speech Assessment (3-4 days)
**Phase 5**: Articles (2-3 days)
**Phase 6**: Polish (2-3 days)

**Total**: 18-25 days for full implementation with tests

---

## Success Criteria

The project is complete when:
1. All 6 feature modules are implemented
2. All routes are working with deep links
3. Mock data flows through entire application
4. Test coverage > 75%
5. Application runs smoothly on web browsers
6. All screens match design references
7. Ready for backend integration (interfaces defined, mock implementations swappable)

---

## Next Steps

Start with **Phase 0** to build the foundation. Do not skip steps—each phase builds on the previous one. Follow the implementation plan sequentially for best results.
