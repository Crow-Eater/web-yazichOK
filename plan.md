# Project Prompt — Flutter (Web) Version

**Goal:** Reproduce the exact same feature set and behavior you described for the iOS SwiftUI app — but implemented as a **Flutter web application** (single codebase for web). Keep the UI/UX, screens, flows and mock-first architecture the same; only adapt platform-specific parts to Flutter and web-friendly libraries/services. Deliverable is a complete specification / prompt that a Flutter dev (or team) can implement.

---

# Required Tech / Libraries (suggested)

* Flutter SDK (stable) targeting web (and mobile-ready if desired).
* State management: **flutter_bloc** with **Cubits** (use `Cubit` and `BlocProvider` for state management, `BlocBuilder`/`BlocConsumer` for UI updates).
* Routing: `go_router` or Navigator 2.0 with a Coordinator-like abstraction (spec uses `go_router` for simplicity with web deep links).
* HTTP: `dio` (with an abstraction layer for mocks).
* Audio:

  * Playback: `just_audio` (supports web via `audio_service` or `html` backend)
  * Recording (web): use `flutter_web_plugins` + JS interop or packages like `record_web` (abstract behind `AudioRecorder` service so mobile/native recording can be plugged later).
* Storage: local in-memory or `shared_preferences` (for mock session/account storage), and local file assets for audio.
* Lottie: `lottie` package.
* UI: Flutter widgets, responsive layout for web.
* Testing: unit tests and widget tests; mocks via `mocktail` / `mockito`.
* State classes: use `freezed` package for immutable state classes with code generation, or `equatable` for simpler cases.

All services must be injected (DI) so mock implementations can be swapped for real implementations later.

**Dependency Injection for Cubits:**

* Use `BlocProvider` to provide Cubits with their dependencies (repositories, managers)
* Example:
  ```dart
  BlocProvider(
    create: (context) => FlashCardsCubit(
      context.read<NetworkManager>(),
    ),
    child: FlashCardsScreen(),
  )
  ```
* For app-wide services, use `MultiBlocProvider` or `RepositoryProvider` at the root level
* Cubits receive dependencies via constructor injection

---

# Deliverables (what the prompt should produce)

Create a feature spec and acceptance-criteria document for developers that includes:

* New UI elements and screens (names, routes, behaviors).
* Cubits/State classes and responsibilities.
* Services/managers (interfaces + mock behavior).
* Navigation routes (paths) for web deep links.
* Data models for flashcards, grammar tests, audio items, users.
* Mock data examples.
* Important UI/UX details (button positions, enabled/disabled state, statistics).
* File / widget name suggestions to keep implementation consistent.

---

# Full Feature Specification (Flutter Web)

## App-wide rules

* Keep clean architecture separation: Widget (View) ↔ Cubit (business logic, state management) ↔ Repositories / Managers (network, audio, auth, storage) ↔ Models.
* Use **Cubit** pattern from `flutter_bloc`:
  * Each feature has a `Cubit` class that extends `Cubit<StateClass>`
  * State classes are immutable data classes (use `freezed` package or `equatable` for state classes)
  * Cubits emit new states via `emit(newState)`
  * UI widgets use `BlocBuilder<Cubit, State>` or `BlocConsumer<Cubit, State>` to react to state changes
  * Use `BlocProvider` to provide Cubits to widget tree
  * Example structure:
    ```dart
    // State class (using freezed or equatable)
    class FlashCardsState extends Equatable {
      final List<WordGroup> groups;
      final bool isLoading;
      final String? error;
      // ... constructors, copyWith, etc.
    }
    
    // Cubit
    class FlashCardsCubit extends Cubit<FlashCardsState> {
      final NetworkManager networkManager;
      FlashCardsCubit(this.networkManager) : super(FlashCardsInitial());
      
      Future<void> loadGroups() async {
        emit(FlashCardsLoading());
        try {
          final groups = await networkManager.getFlashcardGroups();
          emit(FlashCardsLoaded(groups));
        } catch (e) {
          emit(FlashCardsError(e.toString()));
        }
      }
    }
    
    // UI Widget
    BlocBuilder<FlashCardsCubit, FlashCardsState>(
      builder: (context, state) {
        if (state is FlashCardsLoading) return CircularProgressIndicator();
        if (state is FlashCardsError) return Text(state.message);
        if (state is FlashCardsLoaded) {
          return ListView.builder(
            itemCount: state.groups.length,
            itemBuilder: (context, i) => GroupItem(state.groups[i]),
          );
        }
        return SizedBox.shrink();
      },
    )
    ```
* Use `go_router` (or Navigator 2.0) so each screen has a meaningful URL path. Example paths:

  * `/` → main screen
  * `/flashcards` → FlashCards main
  * `/flashcards/add-word` → Add new word
  * `/flashcards/add-group` → Add new group
  * `/flashcards/group/:groupId` → MemoriseWords
  * `/learn` → Learn screen
  * `/learn/grammar-topics` → Grammar topics
  * `/learn/test/:topicId` → Test screen
  * `/learn/listening` → ListeningPractice
  * `/auth/signin` → Sign In
  * `/auth/signup` → Sign Up
  * `/speaking/topics` → Speaking Topics
  * `/speaking/recording` → Recording
  * `/speaking/assessment` → Speaking Assessment
  * `/speaking/results` → Speaking Results
  * `/articles` → Articles Preview
  * `/articles/:articleId` → Article
  * `/articles/:articleId/analysis` → Article Analysis
* All network calls are mocked through a `NetworkRepository` interface. Provide `MockNetworkRepository` that returns deterministic data; replaceable by `HttpNetworkRepository` later.
* All audio is loaded from local assets initially; use `AudioRepository` interface for future remote switching.

---

## Naming convention for widgets / files (suggested)

* Screens / Pages (widgets): `MainScreen`, `FlashCardsScreen`, `AddNewWordScreen`, `AddNewGroupScreen`, `MemoriseWordsScreen`, `LearnScreen`, `GrammarTopicsScreen`, `TestScreen`, `ListeningPracticeScreen`, `SignInScreen`, `SignUpScreen`, `ArticlesPreviewScreen`, `ArticleScreen`, `ArticleAnalysisScreen`, `SpeakingTopicsScreen`, `RecordingScreen`, `SpeakingAssessmentScreen`, `SpeakingResultsScreen`.
* Cubits: `MainCubit`, `FlashCardsCubit`, `MemoriseCubit`, `LearnCubit`, `TestCubit`, `ListeningCubit`, `AuthCubit`, `ArticlesCubit`, `SpeechCubit`.
* State classes: `MainState`, `FlashCardsState`, `MemoriseState`, `LearnState`, `TestState`, `ListeningState`, `AuthState`, `ArticlesState`, `SpeechState` (each with sub-states like `Initial`, `Loading`, `Loaded`, `Error`).
* Repositories/Managers: `NetworkManager` (interface), `MockNetworkManager`, `AudioManager` (interface), `LocalAudioManager`, `RecorderManager` (interface), `WebRecorderManager`, `AuthManager` (interface), `MockAuthManager`.
* Models: `WordGroup`, `FlashCard`, `GrammarTopic`, `Question`, `AnswerOption`, `AudioRecord`, `User`, `SpeakingTopic`, `AssessmentResult`, `Article`, `ArticleAnalysis`, `VocabularyItem`, `GrammarPoint`.

---

# Main Screen

### MainScreen (route `/`)

**Design reference:** `screen_shots/Main screen.png`

**UI Structure**

* Main content area displaying various learning modules and features
* Navigation elements to access different sections of the app
* **Purple UI element** (Flash Cards card/button):
  * Prominent visual element matching the design in screenshot
  * Tapping opens route `/flashcards`
* Other feature cards/buttons (if present in design):
  * Each card represents a different learning module
  * Cards should be visually distinct and tappable
* App bar or header:
  * May include app title/logo
  * User profile/account access (if authenticated)
  * Settings or menu button (optional)

**Behavior**

* Screen serves as the main entry point after authentication
* All navigation cards should be clearly visible and accessible
* Responsive layout for web (centered content, appropriate spacing)
* Navigation should be intuitive and match the visual design

**State Management**

* `MainCubit` handles:
  * User session state
  * Navigation state
  * Feature availability flags
  * Emits `MainState` with sub-states: `MainInitial`, `MainLoaded`, `MainError`

---

# Task 1 — Flash Cards (exact same functionality adapted to Flutter web)

### Entry

* Add a **purple UI element** on the `MainScreen` (matching the design in `screen_shots/Main screen.png`). Tapping opens route `/flashcards`.

### FlashCardsScreen (route `/flashcards`)

**UI**

* `AppBar` / top area: include a `ToolbarItem` on the `.topLeading` edge — implement as an `IconButton` (plus icon) placed in the leading area.

  * Tapping the plus button opens `/flashcards/add-word` (`AddNewWordScreen`).
* Add an overlay floating button aligned `.bottomRight`:

  * Small circular `FloatingActionButton` with a folder icon.
  * Tapping opens `/flashcards/add-group` (`AddNewGroupScreen`).
* Main content: a list of **word groups** (e.g., Travel, Education, Cafe). Each group shows group name and number of words.
* Tapping a group navigates to `/flashcards/group/:groupId` (`MemoriseWordsScreen`) and passes the selected group id.

**Data**

* `FlashCardsCubit` manages `FlashCardsState` which contains `List<WordGroup>`.
  * State: `FlashCardsInitial`, `FlashCardsLoading`, `FlashCardsLoaded(groups)`, `FlashCardsError(message)`
* Groups and words are stored in-memory for the mock with the ability to persist (e.g., local `shared_preferences`) later.

### AddNewWordScreen (`/flashcards/add-word`)

**Design (match `screen_shots/Add word.png`)**

* Fields:

  * **Word** (required)
  * **Transcription** (optional)
  * **Translation** (required — into user’s chosen language)
  * **Group selector** (dropdown/select). Shows existing groups and option to "Create new group" which navigates to AddNewGroup.
* Save button:

  * Validates required fields.
  * Adds the word to the selected group via `FlashCardsCubit.addWord(groupId, word)`.
  * On success, return to `/flashcards` or the group screen.

### AddNewGroupScreen (`/flashcards/add-group`)

**UI**

* Single text field to input group name.
* Save button: validates non-empty name, calls `FlashCardsCubit.addGroup(name)`, then navigates back to `/flashcards` and updates UI.

### MemoriseWordsScreen (`/flashcards/group/:groupId`)

**Design reference:** `screen_shots/Word card.png`
**Functionality**

* Show **one flash card at a time** with:

  * Word
  * Transcription
  * A **reveal translation** button (tapping reveals translation on the card)
* Below the card: `HStack` equivalent — a `Row` containing two buttons:

  * **Don't Know**
  * **Know**
* Pressing either advances to the **next word** in the group.
* The screen must only show words that belong to the selected group.
* When all words are shown:

  * Replace the card area with **statistics**:

    * Count of words user **knew**
    * Count of words user **did not know**
  * Optionally a button to **Restart** or return to group list.

**State management**

* `MemoriseCubit` handles:

  * the current word index
  * counts of known/unknown
  * reveal state
  * next word flow
  * Emits `MemoriseState`: `MemoriseInitial`, `MemoriseInProgress(currentWord, knownCount, unknownCount)`, `MemoriseCompleted(statistics)`

**Edge cases**

* If group has no words — show empty state with CTA to add words.

---

# Task 2 — Grammar Tests (via new “Learn” tab bar item)

### Tab Bar

* Add a new tab (or navigation item) to the app shell:

  * Title: **Learn**
  * Icon: appropriate education icon (use material icon `menu_book` or similar)
  * Clicking opens `/learn` (`LearnScreen`) — for web this is a route.

### LearnScreen (`/learn`)

**Design reference:** `screen_shots/ThemeChoice.png`

**UI Structure**

* Main content displays a list or grid of learning options
* Contains **two main options** (or more as shown in design):

  * **Listening Practice** card/row:
    * Visual card or list item
    * May include icon, title, and description
    * Navigates to `/learn/listening` (`ListeningPracticeScreen`) — Task 3.
  * **Tests** card/row:
    * Visual card or list item
    * May include icon, title, and description
    * Navigates to `/learn/grammar-topics` (`GrammarTopicsScreen`). For Task 2 implement the Tests row behavior only.
* Additional learning options may be present (matching the design):
  * Each option should be tappable and navigate to appropriate screen
  * Visual design should match the screenshot layout

**Layout**

* Cards/rows should be arranged in a scrollable list or grid
* Each item should have clear visual hierarchy
* Spacing and padding should match the design proportions

**Behavior**

* Tapping any learning option navigates to the corresponding screen
* Screen should be responsive for web layouts

### GrammarTopicsScreen (`/learn/grammar-topics`)

* Shows list of grammar topics (mock sample: Articles, Tenses, Prepositions).
* `LearnCubit` or `GrammarTopicsCubit` manages state with mock list of `GrammarTopic` objects (id, title, description, sample question count).
  * State: `GrammarTopicsLoaded(topics)`, `GrammarTopicsLoading`, `GrammarTopicsError`
* Tapping any topic navigates to `/learn/test/:topicId`.

### TestScreen (`/learn/test/:topicId`)

**Design reference:** `screen_shots/Test.png`
**UI Structure**

* **Test Card** (top)

  * Displays the question text
  * Displays the answer options (radio list — single choice)
  * `Check` button — disabled until user selects an answer
* **Result Card** (appears after Check)

  * Shows Correct / Incorrect
  * If incorrect, show the correct answer (and optionally a short explanation)
  * Contains a `Continue` button

**Behavior / Logic**

* `TestCubit` loads mock `List<Question>` for the topic (questions contain text, options, correct option index, optional explanation).
  * State: `TestInitial`, `TestLoading`, `TestQuestionLoaded(question, selectedIndex)`, `TestResultShown(isCorrect, explanation)`, `TestCompleted(summary)`
* Flow:

  1. User reads question and selects an option.
  2. User taps **Check**.
  3. Result card appears below the question card showing Correct/Incorrect and correct answer if needed.
  4. User taps **Continue**:

     * If more questions: show next question; reset UI state (no selected answer shown until user picks one again and Check is enabled after selection).
     * If all questions done: show **Summary card**.
* **Summary card**:

  * How many correct
  * How many incorrect
  * Option to retake or return to topics

**State**

* `TestCubit` tracks and emits state with:

  * currentQuestionIndex
  * selectedOptionIndex
  * answersRecord (list of booleans or a structured result)
  * UI flags to show result card

---

# Task 3 — Listening Practice (web audio player + list)

### ListeningPracticeScreen (`/learn/listening`)

**Design reference:** `screen_shots/Audition.png`
**Layout**

* **Audio Player Card** at top:

  * Shows selected audio title
  * Play / Pause button
  * Seek backward 10s
  * Seek forward 10s
  * Current time and total duration
  * Progress bar (scrubber) optional but recommended
* **List of Audio Records** below:

  * Scrollable list of audio items with title and duration/difficulty icon
  * Tapping selects the audio and updates the player card

**Audio Management**

* Use `AudioManager` abstraction:

  * `LocalAudioManager` loads files from `assets/audio/…` for web
  * Expose methods: `load(AudioRecord)`, `play()`, `pause()`, `seek(Duration)`, `seekForward(10s)`, `seekBackward(10s)`, `positionStream`, `durationStream`, `playbackStateStream`.
* Use `just_audio` or Web Audio API via package that supports web. All player interactions must be handled inside the `AudioManager` so switching to remote URLs (via `NetworkManager`) is straightforward.
* When screen opens show first audio or last selected (persist last selection in `SharedPreferences` or in-memory for mock).

**Behavior**

* Selecting an item updates the audio player card.
* Playback controls operate entirely within the audio card.
* Playback state updates in real time (position, duration).
* Seeking accuracy is required (seek by exact seconds).
* Architecture must make it easy to swap `LocalAudioManager` with `RemoteAudioManager`.

---

# Task 4 — Sign In Screen

### SignInScreen (`/auth/signin`)

**Design reference:** `screen_shots/Sign in.png`
**UI**

* Email TextField

  * Placeholder: `Email`
  * Validation: basic email format (regex / simple `@` check)
* Password TextField

  * Placeholder: `Password`
  * Secure entry
  * Optional show/hide toggle
* Sign In Button

  * Disabled until both fields valid
  * On tap, call `AuthCubit.signIn(email, password)` using `MockAuthManager`
* Navigation text:

  * `Don't have an account? Sign up` — `Sign up` tappable → `/auth/signup`

**Behavior**

* Validate inputs locally
* Mock authentication via `MockAuthManager.signIn(email, password)`:

  * On success: mark session state in `AuthManager` and navigate into main app (home route `/`)
  * On failure: show error message `Invalid credentials`
* `AuthManager` must be replaceable by a real backend integration later.

---

# Task 5 — Sign Up Screen

### SignUpScreen (`/auth/signup`)

**Design reference:** `screen_shots/Sign up.png`
**UI**

* Email field (placeholder: `Email`) — basic format validation
* Password field (placeholder: `Password`) — secure entry, optional toggle
* Repeat password field (placeholder: `Repeat password`) — secure entry; must match password
* Sign Up button — **disabled** until:

  * email valid,
  * password not empty,
  * password equals repeat password
* Navigation text: `Already have an account? Sign in` → navigates back to `/auth/signin`

**Behavior**

* `AuthCubit.signUp(email, password)` calls `MockAuthManager.signUp`
  * State: `AuthInitial`, `AuthLoading`, `AuthAuthenticated(user)`, `AuthError(message)`
* `MockAuthManager`:

  * Stores users in-memory (or in `shared_preferences` for mock persistence)
  * If email already exists: return error `Email already registered`
  * On success: log in user and navigate into main app
* Ensure minimal refactor path for integrating real auth providers (Firebase, OAuth, JWT).

---

# Task 6 — Speech Assessment & Articles

## Speech Assessment Module

### SpeakingTopicsScreen (`/speaking/topics`)

**Design reference:** `screen_shots/Chat.png`

**UI Structure**

* Chat-like interface displaying conversation topics or prompts
* List of speaking topics/conversation starters:
  * Each topic displayed as a message bubble or card
  * Topics may include:
    * Topic title/question
    * Description or context
    * Difficulty level indicator (optional)
* Navigation/action buttons:
  * Select topic button or tap to start recording
  * Back button to return to previous screen

**Behavior**

* User selects a topic to begin speaking practice
* Tapping a topic navigates to `/speaking/recording` with the selected topic
* Topics are loaded via `SpeechCubit` from mock data or `NetworkManager`

**State Management**

* `SpeechCubit` handles:
  * List of available topics
  * Selected topic state
  * Navigation to recording screen
  * State: `SpeechTopicsInitial`, `SpeechTopicsLoaded(topics)`, `SpeechTopicSelected(topic)`

### RecordingScreen (`/speaking/recording`)

**UI Structure**

* **Topic Display** (top):
  * Shows the selected topic/question
  * May include instructions or time limit
* **Recording Controls** (center):
  * Large record button (circular, prominent)
  * Visual indicator when recording (pulsing animation, timer)
  * Stop button (appears during recording)
* **Timer Display**:
  * Shows elapsed recording time
  * May show maximum time limit
* **Action Buttons**:
  * Cancel button (returns to topics)
  * Submit/Finish button (appears after recording stops)

**Behavior**

* User taps record button to start recording
* `RecorderManager.startRecording()` is called
* Recording indicator shows active state
* Timer updates in real-time
* User taps stop to end recording
* After stopping, user can:
  * Re-record (restart recording)
  * Submit recording (navigate to assessment)
* Recording audio is captured via `WebRecorderManager` (web-compatible)

**State Management**

* `SpeechCubit` handles:
  * Recording state (idle, recording, stopped)
  * Timer state
  * Audio blob/URL after recording
  * Navigation to assessment screen
  * State: `RecordingInitial`, `RecordingInProgress(elapsedTime)`, `RecordingStopped(audioBlob)`, `RecordingError(message)`

**Audio Recording**

* Uses `RecorderManager` interface (implemented as `WebRecorderManager` for web)
* Recording must work in browser using Web Audio API or compatible package
* Audio is stored temporarily and passed to assessment screen

### SpeakingAssessmentScreen (`/speaking/assessment`)

**Design reference:** `screen_shots/Assesment.png`

**UI Structure**

* **Assessment Header**:
  * Topic/question being assessed
  * Status indicator (processing, completed)
* **Assessment Results Card**:
  * Overall score or rating
  * Breakdown of assessment criteria:
    * Pronunciation score
    * Fluency score
    * Accuracy score
    * Other metrics (as shown in design)
* **Feedback Section**:
  * Text feedback or comments
  * Highlighted mistakes or suggestions
  * Positive reinforcement
* **Action Buttons**:
  * View detailed results button
  * Try again button (returns to recording)
  * Continue/Next button

**Behavior**

* Screen loads after user submits recording
* `SpeechCubit` processes the recording (mock assessment initially)
* Assessment results are displayed with visual indicators
* User can review feedback and scores
* Navigation options:
  * Try again → returns to `/speaking/recording`
  * View results → navigates to `/speaking/results`
  * Continue → returns to topics or main screen

**State Management**

* `SpeechCubit` handles:
  * Assessment processing state
  * Assessment results data
  * Navigation state
  * State: `AssessmentProcessing`, `AssessmentCompleted(results)`, `AssessmentError(message)`

**Mock Assessment**

* Initially uses mock assessment logic:
  * Generates random or predetermined scores
  * Provides sample feedback text
  * Later replaceable with real speech recognition API

### SpeakingResultsScreen (`/speaking/results`)

**Design reference:** `screen_shots/Speaking results.png`

**UI Structure**

* **Results Summary** (top):
  * Overall performance indicator
  * Total attempts or sessions
  * Average score or progress chart
* **History List**:
  * List of previous speaking attempts:
    * Date/time of attempt
    * Topic/question
    * Score or rating
    * Brief feedback summary
  * Tapping an item shows detailed assessment
* **Statistics Section**:
  * Progress over time (chart or graph)
  * Strengths and areas for improvement
  * Achievement badges or milestones (optional)
* **Action Buttons**:
  * Start new practice session
  * View detailed history
  * Export results (optional)

**Behavior**

* Displays historical speaking assessment data
* User can review past attempts and progress
* Navigation to start new practice session
* Data is stored locally (mock) or fetched from backend

**State Management**

* `SpeechCubit` handles:
  * Historical results data
  * Statistics calculations
  * Progress tracking
  * State: `ResultsInitial`, `ResultsLoaded(history, statistics)`, `ResultsError(message)`

---

## Articles Module

### ArticlesPreviewScreen (`/articles`)

**Design reference:** `screen_shots/Articles list.png`

**UI Structure**

* **Header**:
  * Screen title "Articles" or similar
  * Search bar (optional, if in design)
  * Filter/sort options (optional)
* **Articles List**:
  * Scrollable list of article cards/items
  * Each article item displays:
    * Article title
    * Preview text or excerpt
    * Thumbnail image (if available)
    * Reading time or difficulty level
    * Date published (optional)
* **Empty State**:
  * Message when no articles available
  * Call-to-action to refresh or check back

**Behavior**

* Screen loads list of available articles
* `ArticlesCubit` fetches articles from `NetworkManager` (mock initially)
* Tapping an article navigates to `/articles/:articleId` (`ArticleScreen`)
* List should be scrollable and responsive
* Pull-to-refresh functionality (optional for web)

**State Management**

* `ArticlesCubit` handles:
  * List of articles
  * Loading state
  * Error state
  * Selected article navigation
  * State: `ArticlesInitial`, `ArticlesLoading`, `ArticlesLoaded(articles)`, `ArticlesError(message)`

### ArticleScreen (`/articles/:articleId`)

**Design reference:** `screen_shots/Article.png`

**UI Structure**

* **Article Header**:
  * Article title (large, prominent)
  * Author name and publication date
  * Reading time estimate
* **Article Content**:
  * Scrollable article body text
  * Paragraphs with proper spacing
  * Images or media embedded in content
  * Text formatting (headings, bold, italic, lists)
* **Action Buttons** (bottom or floating):
  * "Analyze Article" button → navigates to `/articles/:articleId/analysis`
  * Bookmark/Save button (optional)
  * Share button (optional)
* **Navigation**:
  * Back button to return to articles list
  * Progress indicator (reading progress bar, optional)

**Behavior**

* Screen loads article content by ID
* `ArticlesCubit` fetches full article content
* Content is displayed in a readable format
* User can scroll through the article
* "Analyze Article" button navigates to analysis screen
* Article reading progress may be tracked (optional)

**State Management**

* `ArticlesCubit` handles:
  * Current article content
  * Loading state
  * Reading progress
  * Bookmark state (if implemented)
  * State: `ArticleInitial`, `ArticleLoading`, `ArticleLoaded(article)`, `ArticleError(message)`

### ArticleAnalysisScreen (`/articles/:articleId/analysis`)

**UI Structure**

* **Analysis Header**:
  * Article title reference
  * Analysis status indicator
* **Analysis Results**:
  * **Vocabulary Analysis**:
    * List of key words/phrases from article
    * Definitions or translations
    * Difficulty level indicators
  * **Grammar Points**:
    * Highlighted grammar structures
    * Explanations and examples
  * **Comprehension Questions** (optional):
    * Questions about article content
    * Answer options or open-ended
  * **Summary**:
    * Article summary or key points
    * Main ideas extraction
* **Action Buttons**:
  * Back to article
  * Retake analysis (if applicable)
  * Export analysis (optional)

**Behavior**

* Screen analyzes the article content
* `ArticlesCubit` processes article for:
  * Vocabulary extraction
  * Grammar identification
  * Comprehension question generation (mock)
* Analysis results are displayed in organized sections
* User can review vocabulary and grammar points
* Navigation back to article or articles list

**State Management**

* `ArticlesCubit` handles:
  * Analysis processing state
  * Analysis results data
  * Vocabulary list
  * Grammar points list
  * State: `AnalysisInitial`, `AnalysisProcessing`, `AnalysisCompleted(analysis)`, `AnalysisError(message)`

**Mock Analysis**

* Initially uses mock analysis:
  * Extracts sample vocabulary from article text
  * Identifies common grammar patterns
  * Generates sample comprehension questions
  * Later replaceable with NLP/ML services

---

## Technical Requirements

* Recording for speech assessment must work in browser (use `WebRecorderManager`) and be abstracted behind `RecorderManager` interface for future mobile support.
* All speech assessment and article data initially uses mock implementations via `NetworkManager` interface.
* Cubits (`SpeechCubit`, `ArticlesCubit`) handle business logic and state management using `flutter_bloc` Cubit pattern.
* Services are injectable for easy replacement with real backend implementations.

---

# Mock Data Examples (must be included with the prompt)

Provide initial mock datasets:

**Flashcards**

```json
[
  {
    "id": "g-travel",
    "title": "Travel",
    "words": [
      { "id": "w-1", "word": "luggage", "transcription": "ˈlʌɡ.ɪdʒ", "translation": "багаж" },
      { "id": "w-2", "word": "departure", "transcription": "dɪˈpɑːr.tʃər", "translation": "відправлення" }
    ]
  },
  {
    "id": "g-cafe",
    "title": "Cafe",
    "words": [
      { "id": "w-10", "word": "barista", "transcription": "bəˈriː.stə", "translation": "бариста" }
    ]
  }
]
```

**Grammar Topics**

```json
[
  { "id": "t-articles", "title": "Articles", "questions": 10 },
  { "id": "t-tenses", "title": "Tenses", "questions": 12 },
  { "id": "t-prepositions", "title": "Prepositions", "questions": 8 }
]
```

**Sample Question**

```json
{
  "id": "q-1",
  "text": "Choose the correct article: ___ apple a day keeps the doctor away.",
  "options": ["A", "An", "The", "No article"],
  "correctIndex": 1,
  "explanation": "'apple' starts with a vowel sound — use 'An'."
}
```

**Listening audio list** (local asset names)

```json
[
  { "id": "a-1", "title": "Travel Dialogue 1", "asset": "assets/audio/travel_dialogue_1.mp3", "duration": "02:10" },
  { "id": "a-2", "title": "Shopping Listening Exercise 2", "asset": "assets/audio/shopping_2.mp3", "duration": "01:45" }
]
```

**Mock users for Auth**

```json
[
  { "email": "test@example.com", "password": "Password123" }
]
```

**Speaking Topics**

```json
[
  {
    "id": "st-1",
    "title": "Describe your favorite vacation",
    "description": "Talk about a memorable trip you took. Include details about the destination, activities, and why it was special.",
    "difficulty": "intermediate",
    "timeLimit": 120
  },
  {
    "id": "st-2",
    "title": "Discuss your daily routine",
    "description": "Describe a typical day in your life from morning to evening.",
    "difficulty": "beginner",
    "timeLimit": 90
  },
  {
    "id": "st-3",
    "title": "Explain a hobby or interest",
    "description": "Talk about something you enjoy doing in your free time. Why do you like it?",
    "difficulty": "intermediate",
    "timeLimit": 120
  }
]
```

**Articles**

```json
[
  {
    "id": "art-1",
    "title": "The Benefits of Learning a New Language",
    "author": "Language Learning Team",
    "publishedDate": "2024-01-15",
    "readingTime": 5,
    "difficulty": "intermediate",
    "excerpt": "Learning a new language opens doors to new cultures, improves cognitive function, and enhances career opportunities...",
    "content": "Full article text with paragraphs, headings, and formatting..."
  },
  {
    "id": "art-2",
    "title": "Effective Study Techniques for Language Learners",
    "author": "Education Expert",
    "publishedDate": "2024-01-20",
    "readingTime": 7,
    "difficulty": "advanced",
    "excerpt": "Discover proven methods to accelerate your language learning journey...",
    "content": "Full article text..."
  }
]
```

**Sample Article Analysis**

```json
{
  "articleId": "art-1",
  "vocabulary": [
    { "word": "cognitive", "definition": "relating to mental processes", "difficulty": "advanced" },
    { "word": "enhance", "definition": "to improve or increase", "difficulty": "intermediate" }
  ],
  "grammarPoints": [
    { "structure": "Present Perfect", "example": "has opened", "explanation": "Used for actions with present relevance" }
  ],
  "comprehensionQuestions": [
    {
      "id": "cq-1",
      "question": "What are three benefits mentioned in the article?",
      "type": "open-ended"
    }
  ],
  "summary": "The article discusses how learning languages improves brain function, cultural understanding, and career prospects."
}
```

---

# Cubit & Service Interfaces (brief)

**FlashCardsCubit extends Cubit<FlashCardsState>**

* Methods: `loadGroups()`, `addGroup(name)`, `addWord(groupId, FlashCard)`, `getWordsForGroup(groupId)`
* State: `FlashCardsInitial`, `FlashCardsLoading`, `FlashCardsLoaded(groups)`, `FlashCardsError(message)`

**MemoriseCubit extends Cubit<MemoriseState>**

* Methods: `loadGroup(groupId)`, `revealTranslation()`, `markKnown()`, `markUnknown()`, `nextWord()`, `reset()`
* State: `MemoriseInitial`, `MemoriseInProgress(currentWord, knownCount, unknownCount)`, `MemoriseCompleted(statistics)`

**TestCubit extends Cubit<TestState>**

* Methods: `loadTopic(topicId)`, `selectOption(index)`, `checkAnswer()`, `continueToNext()`, `reset()`
* State: `TestInitial`, `TestLoading`, `TestQuestionLoaded(question, selectedIndex)`, `TestResultShown(isCorrect, explanation)`, `TestCompleted(summary)`

**ListeningCubit extends Cubit<ListeningState>**

* Methods: `loadRecords()`, `selectRecord(id)`, `play()`, `pause()`, `seekBy(seconds)`
* State: `ListeningInitial`, `ListeningLoaded(records)`, `ListeningPlaying(currentRecord, position, duration)`, `ListeningPaused`, `ListeningError(message)`
* Streams: `positionStream`, `durationStream` from `AudioManager`

**AuthCubit extends Cubit<AuthState>**

* Methods: `signIn(email, password)`, `signUp(email, password)`, `signOut()`, `checkSession()`
* State: `AuthInitial`, `AuthLoading`, `AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthError(message)`

**SpeechCubit extends Cubit<SpeechState>**

* Methods: `loadTopics()`, `selectTopic(id)`, `startRecording()`, `stopRecording()`, `submitRecording()`, `loadAssessmentResults()`, `loadResultsHistory()`
* State: `SpeechInitial`, `SpeechTopicsLoaded(topics)`, `SpeechRecording(elapsedTime)`, `SpeechAssessmentCompleted(results)`, `SpeechResultsLoaded(history, statistics)`, `SpeechError(message)`

**ArticlesCubit extends Cubit<ArticlesState>**

* Methods: `loadArticles()`, `loadArticle(id)`, `analyzeArticle(id)`, `bookmarkArticle(id)`, `getReadingProgress(id)`
* State: `ArticlesInitial`, `ArticlesLoading`, `ArticlesLoaded(articles)`, `ArticleLoaded(article)`, `ArticleAnalysisCompleted(analysis)`, `ArticlesError(message)`

**NetworkManager interface**

* `Future<List<GrammarTopic>> getGrammarTopics()`
* `Future<List<Question>> getQuestions(topicId)`
* `Future<List<WordGroup>> getFlashcardGroups()`
* `Future<List<SpeakingTopic>> getSpeakingTopics()`
* `Future<AssessmentResult> assessRecording(audioBlob, topicId)`
* `Future<List<Article>> getArticles()`
* `Future<Article> getArticle(id)`
* `Future<ArticleAnalysis> analyzeArticle(id)`
* Implement `MockNetworkManager` with the mock data above.

**AudioManager / RecorderManager**

* `AudioManager`: `load(AudioRecord)`, `play()`, `pause()`, `seek`, streams
* `RecorderManager` (for speech assessment): `startRecording()`, `stopRecording()` → returns audio blob / URL (web-friendly)

---

# UI / Accessibility / Responsiveness

* Make UI responsive for web widths (desktop and tablet widths). Components should center and scale, but visual layout should match mobile screenshots in proportions.
* Provide keyboard accessibility for web (tab navigation, Enter key for buttons).
* Use semantic widgets (a11y) where possible.

---

# Acceptance Criteria — per Task (short)

**Task 1 — Flashcards**

* Purple element opens `/flashcards`.
* Toolbar plus button opens Add New Word.
* Bottom-right folder button opens Add New Group.
* Group list displays and tapping opens memorisation screen that shows only words from that group.
* Add, create group, and memorise flows work with mock data and show final statistics.

**Task 2 — Grammar Tests**

* Learn tab exists in shell and opens `/learn`.
* Tapping Tests → `/learn/grammar-topics` with mock topics.
* Topic → `/learn/test/:topicId` flow implemented with Check button enabling, result card displayed, Continue navigates to next question and summary at end.

**Task 3 — Listening Practice**

* `/learn/listening` shows player + list.
* Selecting item loads it to player.
* Play/pause/seek forward/back work and UI updates in real-time.
* Implementation uses `AudioManager` abstraction with local assets.

**Task 4 — Sign In**

* `/auth/signin` with email/password validation.
* Sign-in button disabled until valid.
* Mock AuthManager authenticates or shows error.

**Task 5 — Sign Up**

* `/auth/signup` with email + password + repeat.
* Sign up button disabled until validation passes.
* Duplicate email error handled by mock.

**Task 6 — Speech Assessment**

* `/speaking/topics` displays list of speaking topics in chat-like interface.
* `/speaking/recording` allows user to record speech with timer and controls.
* `/speaking/assessment` shows assessment results with scores and feedback.
* `/speaking/results` displays history and statistics of speaking attempts.
* Recording works in browser via `WebRecorderManager`.
* Mock assessment generates scores and feedback.

**Task 7 — Articles**

* `/articles` displays list of articles with previews.
* `/articles/:articleId` shows full article content with reading interface.
* `/articles/:articleId/analysis` provides vocabulary, grammar, and comprehension analysis.
* Article analysis extracts key information and provides learning insights.
* Mock analysis processes article content locally.

---
